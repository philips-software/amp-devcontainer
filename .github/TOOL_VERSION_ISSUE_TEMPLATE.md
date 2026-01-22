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

---

## ✅ Checklist

### 🧱 amp-devcontainer-base

| Tool | Status |
|------|--------|
| [bats-core](https://github.com/bats-core/bats-core) | - [ ] Up to date |
| [bats-support](https://github.com/bats-core/bats-support) | - [ ] Up to date |
| [bats-assert](https://github.com/bats-core/bats-assert) | - [ ] Up to date |

### ⚙️ amp-devcontainer-cpp

| Tool | Status | Notes |
|------|--------|-------|
| [ARM GNU Toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads) | - [ ] Up to date | Must match GCC version |
| [Clang/LLVM](https://apt.llvm.org/) | - [ ] Up to date | |
| [CPM.cmake](https://github.com/cpm-cmake/CPM.cmake) | - [ ] Up to date | |
| [Mull](https://github.com/mull-project/mull) | - [ ] Up to date | Must be compatible with Clang |
| [include-what-you-use](https://github.com/include-what-you-use/include-what-you-use) | - [ ] Up to date | Must be compatible with Clang |
| [xwin](https://github.com/Jake-Shadle/xwin) | - [ ] Up to date | |

### 🦀 amp-devcontainer-rust

| Tool | Status |
|------|--------|
| [Rust toolchain](https://rust-lang.org/) | - [ ] Up to date |
| [cargo-binstall](https://github.com/cargo-bins/cargo-binstall/releases) | - [ ] Up to date |
