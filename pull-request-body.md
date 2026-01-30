> [!NOTE]
> Before merging this PR, please conduct a manual test checking basic functionality of the updated plug-ins. There are limited automated tests for the VS Code Extension updates.

Updates `sonarsource.sonarlint-vscode` from 4.40.0 to 4.41.0
<details>
<summary>Release notes</summary>
<blockquote>

Bugfixes and technical improvements
</blockquote>
</details>

Updates `ms-vscode.cmake-tools` from 1.21.36 to 1.22.26
<details>
<summary>Release notes</summary>
<blockquote>

Features:
- Add bookmarks and filtering of outline view. [#4539](https://www.github.com/microsoft/vscode-cmake-tools/pull/4539) [@bradphelan](https://www.github.com/bradphelan)
- Add pre-fill project name using current folder name [#4533](https://www.github.com/microsoft/vscode-cmake-tools/pull/4533) [@HO-COOH](https://www.github.com/HO-COOH)
- Add API v5 which adds presets api. [#4510](https://www.github.com/microsoft/vscode-cmake-tools/issues/4510) [@OrkunTokdemir](https://www.github.com/OrkunTokdemir)
- Add an option to extract details about failing tests from CTest output using regular expressions. [#4420](https://www.github.com/microsoft/vscode-cmake-tools/issues/4420)
- Add output parser for [include-what-you-use](https://www.github.com/include-what-you-use). [PR #4548](https://www.github.com/microsoft/vscode-cmake-tools/pull/4548) [@malsyned](https://www.github.com/malsyned)
- Add better return information in the API. [PR #4518](https://www.github.com/microsoft/vscode-cmake-tools/pull/4518)

Improvements:

- In the Test Explorer, associate CTest tests with outermost function or macro invocation that calls `add_test()` instead of with the `add_test()` call itself. [#4490](https://www.github.com/microsoft/vscode-cmake-tools/issues/4490) [@malsyned](https://www.github.com/malsyned)
- Better support of cmake v4.1 and its error index files in cmake-file-api replies [#4575](https://www.github.com/microsoft/vscode-cmake-tools/issues/4575) Contributed by STMicroelectronics
- Added support for clang-cl vendor detection: `${buildKitVendor}`, `${buildKitVersionMajor}`, etc. now expand correctly when using clang-cl on Windows [#4524](https://www.github.com/microsoft/vscode-cmake-tools/pull/4524) [@wchou158](https://www.github.com/wchou158)

Bug Fixes:
- Fix Compiler Warnings not shown in Problems Window [#4567]https://www.github.com/microsoft/vscode-cmake-tools/issues/4567
- Fix bug in which clicking "Run Test" for filtered tests executed all tests instead [#4501](https://www.github.com/microsoft/vscode-cmake-tools/pull/4501) [@hippo91](https://www.github.com/hippo91)
- Migrate macOS CI from deprecated macOS-13 to macOS-15 Image [#4633](https://www.github.com/microsoft/vscode-cmake-tools/pull/4633)
- Ensure Visual Studio developer environment propagation preserves `VCPKG_ROOT`, enabling vcpkg-dependent configure runs after using the Set Visual Studio Developer Environment command. [microsoft/vscode-cpptools#14083](https://www.github.com/microsoft/vscode-cpptools/issues/14083)
- Fix auto-focusing the "Search" input field in the CMake Cache view. [#4552](https://www.github.com/microsoft/vscode-cmake-tools/pull/4552) [@simhof-basyskom](https://www.github.com/simhof-basyskom)
- Remove the demangling feature in the code coverage implementation for now since it doesn't work properly. [PR #4658](https://www.github.com/microsoft/vscode-cmake-tools/pull/4658)
- Fix incorrect IntelliSense configuration when a `UTILITY` has source files. [#4404](https://www.github.com/microsoft/vscode-cmake-tools/issues/4404)
</blockquote>
</details>
