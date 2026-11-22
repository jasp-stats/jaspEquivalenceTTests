# jaspEquivalenceTTests Changelog

> **HOW TO READ AND UPDATE THIS CHANGELOG:**
> 
> This document follows a modified [Keep a Changelog](https://keepachangelog.com/) format adapted for the R/JASP ecosystem. Releases are listed in reverse chronological order (newest first).
> As an example see [jaspModuleTemplate](https://github.com/jasp-stats/jaspModuleTemplate/blob/master/NEWS.md)
> * **Adding New Changes (For Contributors):** All new commits should be logged at the very top of the file under the `# jaspModuleTemplate (development version)` header. Place your bullet point under the appropriate category (`## Added`, `## Fixed`, etc.). 
> * **Issue References:** Please reference the relevant GitHub Issue (if any) at the end of your line (e.g., `([Issue #19](https://github.com/jasp-stats/jaspModuleTemplate/issues/19)`). 
> * **Format Categories:** >   * **Added:** New template features, QML examples, or build tools.
>   * **Changed:** Updates to default configurations, boilerplate code, or dependencies. 
>   * **Fixed:** Bug fixes in the build pipeline, R wrappers, or QML layouts.
>   * **Deprecated / Removed:** Outdated template components or legacy code.


---

# jaspEquivalenceTTests 0.98.0

## Fixed
* Update TOSTER to its 0.9.0 GitHub release, which fixes the ignored one sample test value ([Issue #4701](https://github.com/jasp-stats/jasp-issues/issues/4701)).
* Refresh the JASP testing and graph dependencies, replace obsolete example-test APIs, and explicitly specify standardized bounds in the existing frequentist tests.
* Fix swapped lower- and upper-bound statistics in the one-sample and independent samples equivalence t-test tables.
* Fix the sequential analysis plot of the Bayesian independent samples equivalence t-test failing on rows with a dependent variable value but no group ([Issue #4720](https://github.com/jasp-stats/jasp-issues/issues/4720)).

# jaspEquivalenceTTests 0.97.0

## Fixed
* Bayesian paired samples equivalence t-test: the Bayes factors, posterior masses and prior and posterior plot now use the paired t statistic instead of the independent samples t statistic.
