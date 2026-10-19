# 上游同步（Clackz/Luma-Framework ← Filoppi/Luma-Framework）

## 现状

```
origin   https://github.com/Clackz/Luma-Framework.git     （本 fork，推送目标）
upstream https://github.com/Filoppi/Luma-Framework.git    （上游，只读）
```

**没有独立的「UE 通用 mod 模板」仓库。** 查过：Filoppi 名下只有 `Luma-Framework` 一个相关仓库，
本 fork 的 parent 就是它。所谓模板是上游仓库里的一个**目录**：

| 路径 | 作用 |
|---|---|
| `Source/Games/Unreal Engine/` | **UE 通用 mod 模板**（1632 行，尘白 mod 从它复制派生） |
| `Source/Games/_Template/`、`Source/Games/_Generic Mod/` | 另外两个通用骨架 |
| `Shaders/Unreal Engine/` | UE 通用着色器（`Luma_MotionVec_UE4_Decode.hlsl` 等） |

所以「配 upstream remote」这步其实早就完成——指向 `Filoppi/Luma-Framework` 就等于指向模板所在仓库。
真正要做的是分清**路径归属**。

## 路径归属（2026-10-05 更正）

⚠️ 初稿把尘白目录写成「本 fork 所有、上游不会碰」，**这是错的**。
`git diff --name-status upstream/main main` 里它是 `M` 不是 `A`——**尘白目录本来就在上游**，
由你自己 2026-09-15 提交合入（`4c1902a9 "Snowbreak Containment Zone: add Luma mod"`）。
它同样是上游文件，只是恰好由你维护。

| 归属 | 路径 | 规则 |
|---|---|---|
| **通用（上游所有）** | `Source/Core/**`、`Source/External/**`<br>`Source/Games/Unreal Engine/**`、`Source/Games/_Template/**`、`Source/Games/_Generic Mod/**`<br>`Shaders/Unreal Engine/**`<br>其它游戏的 `Source/Games/<name>/**`<br>`Luma.sln`<br>`.github/workflows/build_and_release.yml`、`.github/workflows/lint.yml` | **不在本 fork 改**。要改就单独开分支提上游 PR，合入后随下次同步回来 |
| **尘白（上游所有、你维护）** | `Source/Games/Snowbreak Containment Zone/**`<br>`Shaders/Snowbreak Containment Zone/**` | 可以改，但**它是上游文件**，所以每次改动都要么提上游 PR、要么明确接受它长期留在 fork-only 差异里 |
| **fork CI（本 fork 新增）** | `.github/workflows/verify.yml`<br>`.github/workflows/build-ue-only.yml`<br>`.github/workflows/build-ue-dev.yml` | 只**新增**，绝不修改上游那两个 workflow |
| **fork 工具（本 fork 新增）** | `Tools/**`（上游无此目录） | 随便改。里面放了 `Tools/.gitattributes`（`*.sh text eol=lf`）——本机 PortableGit 全局 `core.autocrlf=true`，没有这条的话 shell 脚本落库再检出会变成 CRLF，shebang 变 `bash\r` 直接跑不起来 |

当前 `git diff --name-status upstream/main main` 只有 4 项：
3 个 workflow（A）+ 尘白 `main.cpp`（M）。**这是同步成本能压到最低的根本原因**——
冲突面就一个文件，且上游至今只在它上面有过 1 次提交（就是那个 add）。

### 模板漂移

尘白是从 UE 模板复制后独立演化的，两边会持续拉开：

```bash
./Tools/sync-upstream.sh drift
```

打印 `Source/Games/Unreal Engine/main.cpp` → 尘白 `main.cpp` 的行数与 diff 规模
（基线：模板 1632 行 / 尘白上游版 2101 行 / 尘白 fork 版 2168 行）。
上游改了模板时先跑它，判断这次改动要不要搬到尘白。

## 同步步骤

```bash
# 0) 在 Git Bash 里（需要 git 在 PATH 上）
export PATH="/c/Users/99753/.workbuddy/binaries/PortableGit/versions/1.2.0/cmd:$PATH"
export MSYS_NO_PATHCONV=1        # 否则 upstream/main:path 里的冒号会被转成分号
cd "D:/Program Files/Snow/data/game/Game/Binaries/Win64/Temp/prwork/luma"

# 1) 拉上游 + 看差异报告（只读，不改任何东西）
./Tools/sync-upstream.sh

# 2) 把 fork 独有的提交重放到新的上游之上（保持线性历史，推荐）
./Tools/sync-upstream.sh rebase
#    或者保留合并节点：
#    ./Tools/sync-upstream.sh merge

# 3) 只要上游的某几个提交：
#    ./Tools/sync-upstream.sh cherry <sha1> [<sha2> ...]
```

`rebase` 等价于：

```bash
BASE=$(git merge-base main upstream/main)
git rebase --onto upstream/main "$BASE" main
```

有冲突时：

```bash
git status                 # 看哪些文件冲突
#   通用面文件冲突 → 说明我们动了上游文件，反省；优先接受上游版本，改动另开上游 PR
#   尘白面文件冲突 → 只有一种可能：上游也改了它（罕见，至今 1 次），手工合
git checkout --theirs <file>   # 或手工编辑后
git add <file>
git rebase --continue
git rebase --abort             # 想重来
```

## 验证构建

本机没有 MSVC / vcpkg，**只能靠 fork 的 CI**：

- 推任意非 `main` 分支 → `Verify` workflow 自动跑（clang-format + MSVC 编译 + 打包）。
- 推 `main` → `Build UE Mod Only`（Publishing-Release，产物 `Luma-Snowbreak`）+
  `Build Snowbreak (Development)`（产物 `Luma-Snowbreak-Development`）。

```bash
gh run list --repo Clackz/Luma-Framework --limit 5
gh run watch <run-id> --repo Clackz/Luma-Framework
```

编译错误落在 artifact `verify-report-<run id>` 里的 `ci-report/msbuild-snowbreak.log`。

注意：`Verify` 的 lint 只检查**本次改动的行**（`lines-changed-only: true`），
所以别顺手格式化无关代码——尘白 `main.cpp` 的 L90-94 / L1021 是上游遗留告警，
不在改动行内就不会报。

## 隔离约定（降低冲突成本）

1. **尘白的逻辑只写在尘白目录里**。通用代码（`Source/Core/`、`Luma.sln`、其它游戏目录）
   一律不在 fork 改；实在要改（例如 `FSR::Draw()` 缺 `has_context` 判断）就开独立分支提上游 PR。
   ——DLSS/FSR3 切换崩溃的修复正是按这条做的：只改尘白 `main.cpp`，
   `core.hpp` 里「切换类型时无条件清 `sr_suppressed`」那一半留给上游。
2. **fork 的改动尽量走上游 PR**。尘白目录在上游存在，意味着 fork-only 差异是纯粹的债务：
   每多一个 fork-only 提交，下次 rebase 就多一次要重放的冲突面。
   已合入的走 `#207`，在途的走 `#222`（基于 upstream/main）。
3. fork 的 workflow **只新增不修改**，文件名与上游的两个不重合。
4. 上游的 `lint.yml` 在 fork 侧用 API disable（`gh api -X PUT .../disable`），
   **不要删文件**——删了继承文件，下次同步会撞 delete/modify 冲突。
5. 提交前用 `git ls-remote` 核对远端 sha，别信 `git branch -vv`：
   本地 `origin/main` 曾长期是不落地的僵尸 ref（`remote.origin.fetch` 只抓了 main，
   现已补成 `+refs/heads/*:refs/remotes/origin/*`）。
