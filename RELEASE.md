# 发版清单

每次 dispatch `build-ue-only.yml` 发版前，逐项过一遍。这份清单存在的原因见最后一段。

## 1. 对外文案（最容易过期，最先查）

- [ ] `Scripts/Nexus-README.txt` — 打进 Nexus 包的 README。逐条核对：功能描述、已知问题、
      HDR 状态、安装步骤，是否还和**这一版**的实际行为一致。
- [ ] N 网说明页（description）+ 页面 summary — 口径要和上面的 README 一致。
      改法见文末「改 N 网说明页」。
- [ ] GitHub Release 的 body / changelog — 写清这一版改了什么。

**判据**：文案里凡是出现「本版本」「在此版本中」「1.x 起」这类措辞的，都是必查项；
它们一旦没跟着版本走，就是错的。

## 2. 版本号

- [ ] `version` 输入比上一版递增。
- [ ] tag `v<version>` 不存在（CI 会拒绝挪动已发布的 tag，别去绕它）。

## 3. 构建

```
gh workflow run build-ue-only.yml --repo Clackz/Luma-Framework --ref main \
  -f release=true -f nexus=true -f version=<X.Y>
```

- [ ] `Build UE Mod Only` 与 `Build Nexus Package` 两个 job 全绿。
- [ ] 两个 artifact 都在：`Luma-Snowbreak`（上游式包）与 `Luma-Snowbreak-Nexus`（N 网包）。

## 4. 本地部署实测

- [ ] 用 `deploy-luma-addon.py` 拉 CI 产物部署（旧 addon 会被自动备份）。
- [ ] **用 PE 时间戳 + sha256 确认部署的是新构建，别用文件大小判断。**
- [ ] 游戏内实测：DLSS 生效（看 `UE4-SRSTATE`）、切换 SR 类型（DLSS/FSR3/Auto/None）不崩、
      HDR 行为与 README 写的一致。

## 5. 发到 N 网

- [ ] 把 Nexus 包下载到本地：`gh release download v<X.Y> --pattern '*Nexus*'`
- [ ] 先干跑：`nexus_upload_mod_file` 带 `dry_run=true`，确认计划（目标文件、版本、是否归档）。
- [ ] 再真传。**`mod_file_id` 必须用 `nexus_mod_file_targets` 取到的 v3 id**（`7981923`），
      不是 v1 的 `file_id`（`2223`）—— 用错会 404。
- [ ] 复核：`nexus_mod_overview(refresh=true)` 里页面 version 已变成新版本号。

### 改 N 网说明页

```
PATCH https://api.nexusmods.com/v3/mods/23953032610845     # uid，不是 1053
Content-Type: application/json
apikey: <个人 API key>
{"description": "<BBCode 原文>"}
```

- **只送 `\n` 表示换行，绝不要送字面 `<br />`** — 服务端会把 `<br />` 转义成 `&lt;br /&gt;`，
  页面上就会显示一堆字面 `<br />`。
- 成功返回 **204**（空响应体）。
- **v1 读模型有 3~5 分钟缓存**，改完立刻 GET 拿到的还是旧值，别误判成没生效。

## 为什么会有这份清单

2026-10-07 发 1.2 时发现：包内 README 和 N 网说明页都还写着 1.0 时代的
「HDR 重制在本版本已关闭」，而 HDR 从 1.1 就已经重开了 —— 错了整整两个版本没人察觉。

根因是 README 当时内联在 `build-ue-only.yml` 的 PowerShell here-string 里，发版时根本看不到它，
diff 也容易被忽略。现在改成了：

- README 外置成 `Scripts/Nexus-README.txt`，改它就是一次普通的文件 diff；
- 每次打包都会把 README 全文打到构建日志里，发版时抬头就能看见；
- 这份清单把「查文案」放进了发版流程的第一步。
