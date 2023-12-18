# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/) and this project adheres to [Semantic Versioning](https://semver.org/).

## [4.1.0](https://github.com/philips-software/amp-devcontainer/compare/v4.0.2...v4.1.0) (2023-12-18)


### Features

* **deps:** Bump cmake from 3.27.9 to 3.28.0 in /.devcontainer ([#245](https://github.com/philips-software/amp-devcontainer/issues/245)) ([55eb9ed](https://github.com/philips-software/amp-devcontainer/commit/55eb9ed44925a298c2fd5173a6c4fa69d84921a4))
* **deps:** Bump cmake from 3.28.0 to 3.28.1 in /.devcontainer ([#248](https://github.com/philips-software/amp-devcontainer/issues/248)) ([8c81bbb](https://github.com/philips-software/amp-devcontainer/commit/8c81bbba8087e56c79342e8300ea60e6819c362b))
* **deps:** Bump ubuntu from `8eab65d` to `6042500` in /.devcontainer ([#249](https://github.com/philips-software/amp-devcontainer/issues/249)) ([d08e9a0](https://github.com/philips-software/amp-devcontainer/commit/d08e9a0304fb795743282fc6e57b7caef9cc90a3))
* Update xwin from v0.3.1 to v0.5.0 ([#222](https://github.com/philips-software/amp-devcontainer/issues/222)) ([dbb4ce3](https://github.com/philips-software/amp-devcontainer/commit/dbb4ce3bb0c65ab9cfe30e53054b513fae7a7ee8))


### Bug Fixes

* Update xwin to v0.5.0 ([dbb4ce3](https://github.com/philips-software/amp-devcontainer/commit/dbb4ce3bb0c65ab9cfe30e53054b513fae7a7ee8))

## [4.0.2](https://github.com/philips-software/amp-devcontainer/compare/v4.0.1...v4.0.2) (2023-11-13)


### Bug Fixes

* Add 'vX.Y.Z' tag format to Docker image ([#208](https://github.com/philips-software/amp-devcontainer/issues/208)) ([552facf](https://github.com/philips-software/amp-devcontainer/commit/552facf29c2aaee3c6b241801ee9e1256ab42487))

## [4.0.1](https://github.com/philips-software/amp-devcontainer/compare/v4.0.0...v4.0.1) (2023-11-13)


### Bug Fixes

* Make sure all dependency updates are releasable units ([#205](https://github.com/philips-software/amp-devcontainer/issues/205)) ([837f9f9](https://github.com/philips-software/amp-devcontainer/commit/837f9f9eb1229d73340fb7bb728f9920d920b61f))

## [4.0.0](https://github.com/philips-software/amp-devcontainer/compare/v3.1.1...v4.0.0) (2023-11-09)


### ⚠ BREAKING CHANGES

* update clang/LLVM to version 16.0.6 ([#191](https://github.com/philips-software/amp-devcontainer/issues/191))

### Features

* Update clang/LLVM to version 16.0.6 ([#191](https://github.com/philips-software/amp-devcontainer/issues/191)) ([b68d926](https://github.com/philips-software/amp-devcontainer/commit/b68d926f3b059068d52accc0dcc1233ec8bbb490))

## [3.1.1](https://github.com/philips-software/amp-devcontainer/compare/v3.1.0...v3.1.1) (2023-11-07)


### Bug Fixes

* **cosign:** Correctly sign multiple tags ([#192](https://github.com/philips-software/amp-devcontainer/issues/192)) ([bcd2f38](https://github.com/philips-software/amp-devcontainer/commit/bcd2f3895b6780410acf64b1f9b68472cbc9f579))

## [3.1.0](https://github.com/philips-software/amp-devcontainer/compare/v3.0.0...v3.1.0) (2023-10-31)


### Features

* **deps:** Bump cmake from 3.26.4 to 3.27.7 in /.devcontainer ([#188](https://github.com/philips-software/amp-devcontainer/issues/188)) ([5cda3b8](https://github.com/philips-software/amp-devcontainer/commit/5cda3b8332fbb01110a9788f5eaf3b33e0fc388b))
* Publish and review SBOM ([#186](https://github.com/philips-software/amp-devcontainer/issues/186)) ([317c6d6](https://github.com/philips-software/amp-devcontainer/commit/317c6d6d15e084dabcd6798a95978e90ed647c66))
* Update cosign signing ([#175](https://github.com/philips-software/amp-devcontainer/issues/175)) ([1b1946a](https://github.com/philips-software/amp-devcontainer/commit/1b1946a322495f9d7413577e35c9a9061fa1b6b2))


### Bug Fixes

* Pr image cleanup ([#173](https://github.com/philips-software/amp-devcontainer/issues/173)) ([dc50228](https://github.com/philips-software/amp-devcontainer/commit/dc5022803c31054582f44fcb52d73c61b56e21c4))

## [3.0.0](https://github.com/philips-software/amp-devcontainer/compare/v2.6.0...v3.0.0) (2023-10-17)


### ⚠ BREAKING CHANGES

* update gcc-10 to gcc-12 ([#160](https://github.com/philips-software/amp-devcontainer/issues/160))

### Features

* Update gcc-10 to gcc-12 ([#160](https://github.com/philips-software/amp-devcontainer/issues/160)) ([3876ec9](https://github.com/philips-software/amp-devcontainer/commit/3876ec97e68bdb5a19a9f8bcdc69c570abcb6bec))

## [2.6.0](https://github.com/philips-software/amp-devcontainer/compare/v2.5.0...v2.6.0) (2023-10-16)


### Features

* Update bats from 1.9.0 to 1.10.0 ([#163](https://github.com/philips-software/amp-devcontainer/issues/163)) ([958d60d](https://github.com/philips-software/amp-devcontainer/commit/958d60d202df5f185b255eddab158f72f171cc41))
* Update ccache from 4.8.2 to 4.8.3 ([#164](https://github.com/philips-software/amp-devcontainer/issues/164)) ([fdb817b](https://github.com/philips-software/amp-devcontainer/commit/fdb817bbb18444cc6c5b0948f2c77569f3cca6f1))
* Update ccache from 4.8.2. 4.8.3 ([fdb817b](https://github.com/philips-software/amp-devcontainer/commit/fdb817bbb18444cc6c5b0948f2c77569f3cca6f1))
* Update docker-cli from 24.0.4 to 24.0.6 ([#170](https://github.com/philips-software/amp-devcontainer/issues/170)) ([9c275ae](https://github.com/philips-software/amp-devcontainer/commit/9c275ae5e25c176bb4d6ae8f8a60d2f804bdaea8))
* Update xwin from 0.2.14 to 0.3.1 ([#169](https://github.com/philips-software/amp-devcontainer/issues/169)) ([edc9b3f](https://github.com/philips-software/amp-devcontainer/commit/edc9b3f77dc14b1f38c144fc370f6da8efe47fd9))

## [2.5.0](https://github.com/philips-software/amp-devcontainer/compare/v2.4.0...v2.5.0) (2023-07-13)


### Features

* Install ccache-4.8.2 from source ([#110](https://github.com/philips-software/amp-devcontainer/issues/110)) ([ff56bbc](https://github.com/philips-software/amp-devcontainer/commit/ff56bbcf00b256362200ec0b89e75f7f381f6213))
* Update CMake to 3.26.4 ([#112](https://github.com/philips-software/amp-devcontainer/issues/112)) ([8fa0666](https://github.com/philips-software/amp-devcontainer/commit/8fa0666d36be529b39482fa1391bda772440a90d))
* Update Docker to 24.0.4 ([#111](https://github.com/philips-software/amp-devcontainer/issues/111)) ([f7b4540](https://github.com/philips-software/amp-devcontainer/commit/f7b4540915fa8258a0667fbe0a3ac8b513f81561))

## [2.4.0](https://github.com/philips-software/amp-devcontainer/compare/v2.3.0...v2.4.0) (2023-06-20)


### Features

* Add xwin to the container ([#94](https://github.com/philips-software/amp-devcontainer/issues/94)) ([0b79759](https://github.com/philips-software/amp-devcontainer/commit/0b797599632127d6802e8192bf018f62b61d51f5))

## [2.3.0](https://github.com/philips-software/amp-devcontainer/compare/v2.2.0...v2.3.0) (2023-05-17)


### Features

* Add provenance and sbom to image ([af422b9](https://github.com/philips-software/amp-devcontainer/commit/af422b97b5cd386e96b4b82c4fc6e333e5b7b6e2))
* Install static docker-cli from download.docker.com ([#68](https://github.com/philips-software/amp-devcontainer/issues/68)) ([8cebc19](https://github.com/philips-software/amp-devcontainer/commit/8cebc19373ad4ae2e77c2c913c7928e21a1e9380))
* Update bats-core to 1.9.0 and bats-assert to 2.1.0 ([#67](https://github.com/philips-software/amp-devcontainer/issues/67)) ([135c58b](https://github.com/philips-software/amp-devcontainer/commit/135c58b0a16d2fb9d525a6d0a2e4137e41646a49))
* Update cmake to 3.26.3 ([#66](https://github.com/philips-software/amp-devcontainer/issues/66)) ([766f766](https://github.com/philips-software/amp-devcontainer/commit/766f76662ab8a9f682b9237fbf295bb32ce1df1b))
* Update gcovr to 6.0 ([#65](https://github.com/philips-software/amp-devcontainer/issues/65)) ([96e3436](https://github.com/philips-software/amp-devcontainer/commit/96e3436564499d5f1dc254fad595227ee7f15674))

## [2.2.0](https://github.com/philips-software/amp-devcontainer/compare/v2.1.0...v2.2.0) (2023-02-01)


### Features

* Build multi-platform image ([#4](https://github.com/philips-software/amp-devcontainer/issues/4)) ([839fb0d](https://github.com/philips-software/amp-devcontainer/commit/839fb0dc61051b25926ac847bfe12646284a31a7))
* Fix tagged release workflow ([#15](https://github.com/philips-software/amp-devcontainer/issues/15)) ([1ee833b](https://github.com/philips-software/amp-devcontainer/commit/1ee833bcb69390138e30e600b62bd166a62d006f))
* Include lld as an alternative to the gold and bfd linkers ([d8adb0b](https://github.com/philips-software/amp-devcontainer/commit/d8adb0bc3ec9eb01d84c5563ce37bfc30e45c70f))


### Bug Fixes

* Set executable bit on shell scripts ([33406a3](https://github.com/philips-software/amp-devcontainer/commit/33406a3d936cb0da465e9df0f27415f4a861d59d))
* Update GITHUB_TOKEN permissions ([a4a2e1a](https://github.com/philips-software/amp-devcontainer/commit/a4a2e1a4921292beed9810fa9c099e56069cbdcb))
* Update GITHUB_TOKEN permissions ([90ca544](https://github.com/philips-software/amp-devcontainer/commit/90ca54409b0c8b20c334e9a2a284647103f76af1))

## [2.1.0](https://github.com/philips-software/amp-devcontainer/compare/amp-devcontainer-v2.0.0...amp-devcontainer-v2.1.0) (2023-01-31)


### Features

* Build multi-platform image ([#4](https://github.com/philips-software/amp-devcontainer/issues/4)) ([839fb0d](https://github.com/philips-software/amp-devcontainer/commit/839fb0dc61051b25926ac847bfe12646284a31a7))
* Include lld as an alternative to the gold and bfd linkers ([d8adb0b](https://github.com/philips-software/amp-devcontainer/commit/d8adb0bc3ec9eb01d84c5563ce37bfc30e45c70f))


### Bug Fixes

* Update GITHUB_TOKEN permissions ([a4a2e1a](https://github.com/philips-software/amp-devcontainer/commit/a4a2e1a4921292beed9810fa9c099e56069cbdcb))

## [2.1.0](https://github.com/philips-software/amp-devcontainer/compare/amp-devcontainer-v2.0.0...amp-devcontainer-v2.1.0) (2023-01-30)


### Features

* Build multi-platform image ([#4](https://github.com/philips-software/amp-devcontainer/issues/4)) ([839fb0d](https://github.com/philips-software/amp-devcontainer/commit/839fb0dc61051b25926ac847bfe12646284a31a7))


### Bug Fixes

* Set executable bit on shell scripts ([33406a3](https://github.com/philips-software/amp-devcontainer/commit/33406a3d936cb0da465e9df0f27415f4a861d59d))
* Update GITHUB_TOKEN permissions ([a4a2e1a](https://github.com/philips-software/amp-devcontainer/commit/a4a2e1a4921292beed9810fa9c099e56069cbdcb))
* Update GITHUB_TOKEN permissions ([90ca544](https://github.com/philips-software/amp-devcontainer/commit/90ca54409b0c8b20c334e9a2a284647103f76af1))
