Luma for Snowbreak: Containment Zone - complete package
=======================================================

What this is
------------
Super Resolution (DLSS) for Snowbreak: Containment Zone. The game ships without any
DLSS support at all, and this build adds it. It is a build of the Luma Framework
running as a ReShade add-on.

This is the complete package: unlike the archive distributed on Nexus, it carries
ReShade itself (as dxgi.dll) and the NVIDIA DLSS runtime (nvngx_dlss.dll), so it can
be extracted into a game folder that has neither.

Who this is for
---------------
A clean install - a game folder with no ReShade and no DLSS runtime in it.

Do NOT use this archive if any of the following is true - take the Nexus archive
(slim, no dxgi.dll, no nvngx_dlss.dll) instead:

  * ReShade is already installed for this game. ReShade, OptiScaler and most other
    overlays all load from the same slot, dxgi.dll. Extracting this one replaces
    whatever is sitting there, silently and without asking.
  * You use a DLSS-NR build (renodx-dlss, the NR fork of OptiScaler, ...). Those work
    by replacing nvngx_dlss.dll with their own patched copy. Extracting this archive
    overwrites it and the NR version stops working.

Contents
--------
  Luma-Snowbreak Containment Zone.addon
      the mod itself
  Luma/Global/ , Luma/Includes/ , Luma/Snowbreak Containment Zone/
      the shaders the mod mounts when it runs
  Luma/d3dcompiler_47.dll
      shader compiler the mod uses at runtime
  dxgi.dll
      ReShade 6.x with add-on support, renamed to the proxy slot Luma loads through
  nvngx_dlss.dll
      the NVIDIA DLSS runtime the mod calls into
  LICENSE.md
      the licence of the code this build is made from
  SHA256SUMS.txt
      SHA-256 of every file in this archive
  build-info.txt
      which version and commit this build came from, and what it was built with

Requirements
------------
* An NVIDIA RTX graphics card. DLSS Super Resolution does not run on GTX.
* Windows 10/11, 64-bit.

Installation
------------
1. Extract this archive into the folder that holds the game executable, merging
   folders and replacing files when updating.
2. Launch the game and press Home. The ReShade overlay should come up, and the
   add-on list in its Add-ons tab should contain Luma.
3. Open the Luma tab and set Super Resolution to DLSS.

Notes
-----
* If you already have a newer nvngx_dlss.dll and use DLSS Swapper, keep yours - a
  runtime shipped here is only a convenient default, not a requirement.
* Luma's HDR remastering is enabled on HDR displays by default. Untick "Enable Luma
  HDR" in the Luma tab once if you want SDR output. Leaving a stage and returning to
  the main lobby could once leave the loading screen stuck while it was on; that is
  fixed from 1.1 onwards.
* If you do get stuck on a loading screen after leaving a stage, press Esc a few
  times to back out to the main lobby screen. The world starts rendering about a
  second after the lobby screen is up, and the loading screen clears with it. While
  you are still on the stage-result panels it does not clear on its own - one run sat
  there for 99 seconds and never recovered. The game itself stays alive and at full
  frame rate throughout.
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

ReShade is by Crosire and the ReShade contributors:
https://reshade.me

nvngx_dlss.dll is a component of the NVIDIA RTX SDK, included under the NVIDIA RTX
SDK License. DLSS is a trademark of NVIDIA Corporation. The DLSS SDK, including its
licence terms, is available at https://github.com/NVIDIA/DLSS

This mod is free. If you paid for it, you were overcharged.

中文说明
========

这是什么
--------
《尘白禁区》（Snowbreak: Containment Zone）原生不支持 DLSS，本 mod 为其加入
DLSS 超分。它基于 Luma Framework，以 ReShade 插件的形式运行。

本包为**完整版**：与 N 网发布的精简版不同，它自带 ReShade（即 dxgi.dll）和
NVIDIA 的 DLSS 运行时（nvngx_dlss.dll），可以直接解压进一个两者都没有的游戏目录。

适用人群
--------
全新安装——游戏目录里既没有 ReShade，也没有 DLSS 运行时。

以下任一情况请不要用本包，改用 N 网的精简版（不含 dxgi.dll、不含
nvngx_dlss.dll）：

  * 已经给本游戏装过 ReShade。ReShade、OptiScaler 以及大多数叠加工具都占用
    同一个槽位 dxgi.dll，解压本包会静默替换掉你原本能用的那一份。
  * 正在用 DLSS-NR 类方案（renodx-dlss、OptiScaler 的 NR 版本等）。它们靠替换
    nvngx_dlss.dll 工作，解压本包会把它们的那份覆盖掉，NR 随之失效。

包含内容
--------
  Luma-Snowbreak Containment Zone.addon
      mod 本体
  Luma/Global/ 、 Luma/Includes/ 、 Luma/Snowbreak Containment Zone/
      mod 运行时挂载的着色器
  Luma/d3dcompiler_47.dll
      mod 运行时使用的着色器编译器
  dxgi.dll
      ReShade 6.x（带 add-on 支持），已改名为 Luma 加载所用的代理槽名
  nvngx_dlss.dll
      mod 调用的 NVIDIA DLSS 运行时
  LICENSE.md
      本构建所基于代码的许可
  SHA256SUMS.txt
      本包内每个文件的 SHA-256
  build-info.txt
      本构建来自哪个版本、哪个 commit、用什么构建

前置要求
--------
* NVIDIA RTX 显卡。DLSS 超分在 GTX 上不可用。
* Windows 10/11 64 位。

安装
----
1. 将本压缩包解压到游戏可执行文件所在目录，合并文件夹，更新时覆盖。
2. 启动游戏并按 Home。应能呼出 ReShade 面板，其 Add-ons 标签页的插件列表中
   应出现 Luma。
3. 打开 Luma 标签页，将 Super Resolution 设为 DLSS。

注意事项
--------
* 如果你已经有更新的 nvngx_dlss.dll，或用 DLSS Swapper 管理过它，那就保留你
  自己那份——包内的运行时只是个方便可用的默认值，并非必须。
* Luma 的 HDR 重制在 HDR 显示器上默认开启。需要 SDR 输出的话，在 Luma 标签页
  里取消勾选 "Enable Luma HDR" 一次即可。开启时退出副本回到主界面曾可能一直
  卡在加载界面——游戏本身仍在满帧运行，但加载界面不消失；该问题自 1.1 起已
  修复。
* 退出副本后若卡在加载界面，连按几次 ESC 退回主界面即可。回到主界面约一秒后
  场景开始渲染，加载界面随之消失。停在副本结算界面时它不会自行消失——我们等
  过 99 秒也未恢复。此期间游戏一直在满帧运行。
* 安装或更新后的首次启动会编译 mod 的着色器，比平时慢；之后不会。
* 若你同时使用 OptiScaler，不要让任一工具覆盖对方的代理文件。

署名与许可
----------
本 mod 基于 Filippo Tarpini（Pumbo）的 Luma Framework 构建：
https://github.com/Filoppi/Luma-Framework
遵循其许可使用：允许再分发，但须署名作者；商业用途需事先征得作者同意。完整
许可文本见包内 LICENSE.md。所有渲染相关工作均由他完成，我们所做的仅为《尘白
禁区》的游戏预设、对应着色器挂载，以及本包的打包。

ReShade 由 Crosire 与 ReShade 贡献者开发：https://reshade.me

nvngx_dlss.dll 为 NVIDIA RTX SDK 的组件，依 NVIDIA RTX SDK License 随包分发。
DLSS 是 NVIDIA Corporation 的商标。DLSS SDK 及其许可条款见
https://github.com/NVIDIA/DLSS

本 mod 为免费分享。如果你是花钱购买的，请尽快退款。
