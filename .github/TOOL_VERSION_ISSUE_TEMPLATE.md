<!-- markdownlint-disable MD041 -->

## 🔧 Description

It's time for our quarterly tool version check! This issue serves as a reminder to evaluate and update the tools in our container images.

> [!NOTE]
> Our philosophy: always ship the **latest stable tool versions** on the **latest Ubuntu [LTS](https://ubuntu.com/about/release-cycle)**.

### 📋 How to use this checklist

1. Check each tool against its latest release
2. Update versions where needed via PR
3. Document any intentional version holds in the comments below
4. Check off items as you verify them

> [!TIP]
> Most dependencies are managed by Dependabot. The tools below require manual review.

## ✅ Checklist

### 🧱 amp-devcontainer-base

- [ ] [bats-core](https://github.com/bats-core/bats-core)
- [ ] [bats-support](https://github.com/bats-core/bats-support)
- [ ] [bats-assert](https://github.com/bats-core/bats-assert)

### ⚙️ amp-devcontainer-cpp

- [ ] [ARM GNU Toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads) — *must match GCC version*
- [ ] [Clang/LLVM](https://apt.llvm.org/)
- [ ] [CPM.cmake](https://github.com/cpm-cmake/CPM.cmake)
- [ ] [Mull](https://github.com/mull-project/mull) — *must be compatible with Clang*
- [ ] [include-what-you-use](https://github.com/include-what-you-use/include-what-you-use) — *must be compatible with Clang*
- [ ] [xwin](https://github.com/Jake-Shadle/xwin)

### 🦀 amp-devcontainer-rust

- [ ] [Rust toolchain](https://rust-lang.org/)
- [ ] [cargo-binstall](https://github.com/cargo-bins/cargo-binstall/releases)
