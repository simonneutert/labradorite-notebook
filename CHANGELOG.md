# Changelog

All notable changes to this project will be documented in this file.

new entry format:

```markdown
### next (yyyy/mm/dd)

- [PR#](url) Description. - [@user](url)
```

---

### next (yyyy/mm/dd)

- [#197](https://github.com/simonneutert/labradorite-notebook/pull/197) adds gpx to allowed mime type uploads - [@simonneutert](https://github.com/simonneutert)

### v0.6.0 (2025/08/19)

See [UPGRADING](./UPGRADING.md) for details.

- [PR#193](https://github.com/simonneutert/labradorite-notebook/pull/193) **Major Search Engine Migration**: Complete rewrite from Tantiny (Rust) to SQLite FTS5 with comprehensive code refactoring and architectural improvements. Eliminates external dependencies, improves deployment simplicity, and enhances performance with better platform support. Includes extensive code quality improvements addressing all PR review feedback with method complexity reduction, better separation of concerns, and improved maintainability. All changes maintain full backward compatibility. - [@simonneutert](https://github.com/simonneutert)

### v0.5.14 (2025/08/02)

- Dependencies updated. - [@simonneutert](https://github.com/simonneutert)

### v0.5.13 (2025/06/26)

- Dependencies updated. - [@simonneutert](https://github.com/simonneutert)

### v0.5.12 (2025/06/09)

- Dependencies updated. - [@simonneutert](https://github.com/simonneutert)

### v0.5.11 (2025/05/08)

- Dependencies updated. - [@simonneutert](https://github.com/simonneutert)

### v0.5.10 (2025/04/27)

- Dependencies updated. - [@simonneutert](https://github.com/simonneutert)

### v0.5.9 (2025/03/12)

- Dependencies updated. - [@simonneutert](https://github.com/simonneutert)

### v0.5.8 (2025/03/07)

- Dependencies updated. - [@simonneutert](https://github.com/simonneutert)

### v0.5.7 (2025/02/16)

- [#166](https://github.com/simonneutert/labradorite-notebook/pull/132)
  Dependencies and version locks. -
  [@simonneutert](https://github.com/simonneutert)

### v0.5.0 (2024/09/01)

- [#132](https://github.com/simonneutert/labradorite-notebook/pull/132) All new
  posts' title will be set to the current date. Please visit the
  [UPGRADING](UPGRADING.md) readme file, too. -
  [@simonneutert](https://github.com/simonneutert)
- [#106](https://github.com/simonneutert/labradorite-notebook/pull/106) Updates
  Ruby, Node.js, and Nokogiri versions, and replace unmaintained tag JS
  framework with "use-bootstrap-tag". -
  [@simonneutert](https://github.com/simonneutert)

### 0.4.4 (2023/11/17)

- Updates dependencies and ci config

### 0.4.3 (2023/10/23)

- Updates NodeJS install, switches prod image to debian

### 0.4.2 (2023/10/15)

- Replaces OpenStruct with Struct

### 0.4.1 (2023/10/15)

- Adds Rubocop to CI
- Updates gems and bundler itself 🚀

### 0.3.0 (2023/07/03)

- Requires Ruby v3+ by @simonneutert in #42

### 0.2.0 (2023/07/03)

- Bump solargraph from 0.47.2 to 0.48.0 by @dependabot in #26
- Bump rubocop from 1.38.0 to 1.48.0 by @dependabot in #27
- Bump rack-unreloader from 2.0.0 to 2.1.0 by @dependabot in #25
- Bump rackup from 0.2.2 to 2.0.0 by @dependabot in #29
- Bump puma from 5.6.5 to 6.1.1 by @dependabot in #28

### 0.1.7 (2023/02/05)

- sets utf-8 docker locales
- uppy setup to non-js-module, but script source
- upload filename utf-8 force encoding, replaces unknown character with
  underscore

### 0.1.6 (2022/12/27)

- patches vulnerable version of Nokogiri

### 0.1.5 (2022/12/20)

- fixes #21 (#22)

### 0.1.4 (2022/11/05)

- preview on preview button not as background tasks

### 0.1.3 (2022/11/03)

- supports code block in markdown

### 0.1.2 (2022/10/29)

- highlights search text in search results with yellow marker 🖍 -
  [@simonneutert](https://github.com/simonneutert).

### 0.1.1 (2022/10/22)

- drops shipping of default memos, allowing easier upgrades -
  [@simonneutert](https://github.com/simonneutert).

### 0.1.0 (2022/10/22)

- Initial public release - [@simonneutert](https://github.com/simonneutert).
