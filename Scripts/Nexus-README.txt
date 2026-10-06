Luma for Snowbreak: Containment Zone
====================================

What this is
------------
Super Resolution (DLSS) for Snowbreak: Containment Zone. The game ships without any
DLSS support at all, and this build adds it. It is a build of the Luma Framework
running as a ReShade add-on, packaged for Nexus.

Contents
--------
  Luma-Snowbreak Containment Zone.addon
      the mod itself
  Luma/Global/ , Luma/Includes/ , Luma/Snowbreak Containment Zone/
      the shaders the mod mounts when it runs
  Luma/d3dcompiler_47.dll
      shader compiler the mod uses at runtime
  LICENSE.md
      the licence of the code this build is made from
  SHA256SUMS.txt
      SHA-256 of every file in this archive
  build-info.txt
      which commit this build came from, and what it was built with

Requirements
------------
ReShade 6.x or newer, with add-on support, must already be installed for the game.
This archive deliberately does NOT contain ReShade. ReShade loads from a fixed slot,
usually dxgi.dll, and that slot may already be taken by an existing ReShade install
or by another tool such as OptiScaler. Writing our own copy there would silently
overwrite whatever the user already has working.

Installation
------------
1. Confirm the ReShade overlay opens in game (Home key).
2. Extract this archive into the folder that holds the game executable, merging
   folders and replacing files when updating.
3. Launch the game and press Home. The add-on list should now contain Luma.
4. Open the Luma tab and set Super Resolution to DLSS.

Notes
-----
* Luma's HDR remastering is enabled on HDR displays by default. Untick
  "Enable Luma HDR" in the Luma tab once if you want SDR output. Leaving a
  stage and returning to the main lobby could once leave the loading screen
  stuck while it was on; that is fixed from 1.1 onwards.
* If you do get stuck on a loading screen after leaving a stage, press Esc a
  few times to back out to the main lobby screen. The world starts rendering
  about a second after the lobby screen is up, and the loading screen clears
  with it. While you are still on the stage-result panels it does not clear on
  its own - one run sat there for 99 seconds and never recovered. The game
  itself stays alive and at full frame rate throughout.
* The first launch after installing or updating compiles the mod's shaders and is
  slower than usual. Later launches are not.
* If you run OptiScaler as well, do not let either tool replace the other's proxy.

Credits and licence
-------------------
This is a build of the Luma Framework by Filippo Tarpini (Pumbo):
https://github.com/Filoppi/Luma-Framework
Used under its licence, which allows redistribution as long as the author is
credited, and requires asking the author first for commercial use. The full licence
text is in LICENSE.md, shipped in this archive.
The rendering work is all his. Only the game-specific preset for Snowbreak:
Containment Zone, its shaders mount, and the packaging of this archive are ours.

This mod is free. If you paid for it, you were overcharged.

中文说明
========

这是什么
--------
《尘白禁区》（Snowbreak: Containment Zone）原生不支持 DLSS，本 mod 为其加入
DLSS 超分。它基于 Luma Framework，以 ReShade 插件的形式运行，本包为 Nexus
发布版。

包含内容
--------
  Luma-Snowbreak Containment Zone.addon
      mod 本体
  Luma/Global/ 、Luma/Includes/ 、Luma/Snowbreak Containment Zone/
      mod 运行时挂载的着色器
  Luma/d3dcompiler_47.dll
      mod 运行时使用的着色器编译器
  LICENSE.md
      本构建所基于代码的许可
  SHA256SUMS.txt
      本包内每个文件的 SHA-256
  build-info.txt
      本构建来自哪个 commit、用什么构建

前置要求
--------
需先为游戏装好 ReShade 6.x 或更新版本（带 add-on 支持）。本 mod 不含 ReShade。
ReShade 从固定槽位加载（通常是 dxgi.dll），该槽位可能已被你现有的 ReShade
或 OptiScaler 之类工具占用，写入我们自己的副本会覆盖掉你原本能用的那份。

安装
----
1. 确认游戏内按 Home 能呼出 ReShade 面板。
2. 将本压缩包解压到游戏可执行文件所在目录，合并文件夹，更新时覆盖。
3. 启动游戏并按 Home，插件列表中应出现 Luma。
4. 打开 Luma 标签页，将 Super Resolution 设为 DLSS。

注意事项
--------
* Luma 的 HDR 重制在 HDR 显示器上默认开启。需要 SDR 输出的话，在 Luma
  标签页里取消勾选 "Enable Luma HDR" 一次即可。开启时退出副本回到主界面
  曾可能一直卡在加载界面——游戏本身仍在满帧运行，但加载界面不消失；该问题
  自 1.1 起已修复。
* 退出副本后若卡在加载界面，连按几次 ESC 退回主界面即可。回到主界面约一秒
  后场景开始渲染，加载界面随之消失。停在副本结算界面时它不会自行消失——我
  们等过 99 秒也未恢复。此期间游戏一直在满帧运行。
* 安装或更新后的首次启动会编译 mod 的着色器，比平时慢；之后不会。
* 若你同时使用 OptiScaler，不要让任一工具覆盖对方的代理文件。

署名与许可
----------
本 mod 基于 Filippo Tarpini（Pumbo）的 Luma Framework 构建：
https://github.com/Filoppi/Luma-Framework
遵循其许可使用：允许再分发，但须署名作者；商业用途需事先征得作者同意。完整
许可文本见包内 LICENSE.md。所有渲染相关工作均由他完成，我们所做的仅为《尘
白禁区》的游戏预设、对应着色器挂载，以及本包的打包。

本 mod 为免费分享。如果你是花钱购买的，请尽快退款。
