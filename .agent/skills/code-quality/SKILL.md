---
name: Code Quality (SonarCloud, CheckStyle, SpotBugs)
description: Skill for enforcing code quality with SonarCloud analysis, CheckStyle rules, SpotBugs detection, and quality gate configuration for continuous code quality assurance.
---

# Code Quality Skill

## Overview
This skill covers enforcing code quality using industry-standard tools: **SonarCloud** (multi-language), **CheckStyle** (Java), **SpotBugs** (Java), and quality gates to ensure code meets defined standards before merging/deploying.

---

## 1. SonarCloud — Multi-Language Quality Analysis

### Setup

#### GitHub Actions
```yaml
# .github/workflows/sonar.yml
name: SonarCloud Analysis

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  sonarcloud:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for accurate blame

      # Node.js project
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install & Test with Coverage
        run: |
          npm ci
          npm run test -- --coverage --reporter=lcov

      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

#### sonar-project.properties
```properties
# Required
sonar.organization=my-org
sonar.projectKey=my-org_my-project
sonar.projectName=My Project

# Sources
sonar.sources=src
sonar.tests=tests
sonar.test.inclusions=**/*.test.ts,**/*.spec.ts,**/*.test.js,**/*.spec.js

# Exclusions
sonar.exclusions=**/node_modules/**,**/dist/**,**/coverage/**,**/*.config.*,**/migrations/**
sonar.test.exclusions=**/node_modules/**

# Coverage
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.typescript.lcov.reportPaths=coverage/lcov.info

# Encoding
sonar.sourceEncoding=UTF-8

# Quality Gate (can also be set in SonarCloud UI)
# sonar.qualitygate.wait=true
```

#### Java (Maven)
```xml
<!-- pom.xml -->
<properties>
    <sonar.organization>my-org</sonar.organization>
    <sonar.projectKey>my-org_my-project</sonar.projectKey>
    <sonar.host.url>https://sonarcloud.io</sonar.host.url>
    <sonar.coverage.jacoco.xmlReportPaths>
        ${project.build.directory}/site/jacoco/jacoco.xml
    </sonar.coverage.jacoco.xmlReportPaths>
</properties>

<!-- Run: mvn verify sonar:sonar -Dsonar.token=$SONAR_TOKEN -->
```

### SonarCloud Quality Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| **Bugs** | Code that is objectively wrong | 0 (A rating) |
| **Vulnerabilities** | Security weaknesses | 0 (A rating) |
| **Code Smells** | Maintainability issues | < 5% of lines |
| **Coverage** | Test code coverage | ≥ 80% |
| **Duplications** | Duplicated code blocks | < 3% |
| **Security Hotspots** | Code requiring security review | All reviewed |
| **Technical Debt** | Time to fix all code smells | < 5% of dev time |

### Custom Quality Gate
```
Quality Gate: "Strict Production Gate"

Conditions (on New Code):
├── Coverage on New Code           ≥ 80%
├── Duplicated Lines on New Code   ≤ 3%
├── Maintainability Rating         = A
├── Reliability Rating             = A
├── Security Rating                = A
├── Security Hotspots Reviewed     = 100%
└── Blocker Issues                 = 0

Conditions (on Overall Code):
├── Coverage                       ≥ 70%
├── Duplicated Lines Density       ≤ 5%
├── Maintainability Rating         = A
├── Reliability Rating             ≥ B
└── Security Rating                = A
```

---

## 2. CheckStyle — Java Code Style Enforcement

### Setup (Maven)
```xml
<!-- pom.xml -->
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-checkstyle-plugin</artifactId>
    <version>3.3.1</version>
    <dependencies>
        <dependency>
            <groupId>com.puppycrawl.tools</groupId>
            <artifactId>checkstyle</artifactId>
            <version>10.14.0</version>
        </dependency>
    </dependencies>
    <configuration>
        <configLocation>checkstyle.xml</configLocation>
        <consoleOutput>true</consoleOutput>
        <failsOnError>true</failsOnError>
        <violationSeverity>warning</violationSeverity>
        <includeTestSourceDirectory>true</includeTestSourceDirectory>
    </configuration>
    <executions>
        <execution>
            <id>validate</id>
            <phase>validate</phase>
            <goals><goal>check</goal></goals>
        </execution>
    </executions>
</plugin>
```

### Setup (Gradle)
```groovy
// build.gradle
plugins {
    id 'checkstyle'
}

checkstyle {
    toolVersion = '10.14.0'
    configFile = file("${rootDir}/checkstyle.xml")
    maxWarnings = 0
    maxErrors = 0
}

tasks.withType(Checkstyle) {
    reports {
        xml.required = true
        html.required = true
    }
}
```

### checkstyle.xml (Recommended Configuration)
```xml
<?xml version="1.0"?>
<!DOCTYPE module PUBLIC "-//Checkstyle//DTD Checkstyle Configuration 1.3//EN"
        "https://checkstyle.org/dtds/configuration_1_3.dtd">

<module name="Checker">
    <property name="severity" value="warning"/>
    <property name="fileExtensions" value="java"/>

    <!-- File-level checks -->
    <module name="FileLength">
        <property name="max" value="500"/>
    </module>
    <module name="FileTabCharacter"/>
    <module name="NewlineAtEndOfFile"/>

    <module name="TreeWalker">
        <!-- Naming Conventions -->
        <module name="TypeName"/>              <!-- UpperCamelCase for classes -->
        <module name="MethodName"/>            <!-- lowerCamelCase for methods -->
        <module name="ConstantName"/>          <!-- UPPER_SNAKE_CASE for constants -->
        <module name="LocalVariableName"/>     <!-- lowerCamelCase -->
        <module name="ParameterName"/>         <!-- lowerCamelCase -->
        <module name="MemberName"/>            <!-- lowerCamelCase -->

        <!-- Code Quality -->
        <module name="MethodLength">
            <property name="max" value="50"/>  <!-- SRP: Keep methods small -->
        </module>
        <module name="ParameterNumber">
            <property name="max" value="5"/>   <!-- Too many params = smell -->
        </module>
        <module name="CyclomaticComplexity">
            <property name="max" value="10"/>  <!-- Reduce branching -->
        </module>
        <module name="BooleanExpressionComplexity">
            <property name="max" value="3"/>
        </module>

        <!-- Imports -->
        <module name="UnusedImports"/>
        <module name="RedundantImport"/>
        <module name="AvoidStarImport"/>

        <!-- Blocks -->
        <module name="NeedBraces"/>            <!-- Always use braces -->
        <module name="EmptyBlock"/>
        <module name="LeftCurly"/>
        <module name="RightCurly"/>

        <!-- Design -->
        <module name="FinalClass"/>
        <module name="HideUtilityClassConstructor"/>
        <module name="InterfaceIsType"/>
        <module name="VisibilityModifier"/>

        <!-- Javadoc -->
        <module name="MissingJavadocMethod">
            <property name="scope" value="public"/>
            <property name="minLineCount" value="2"/>
        </module>

        <!-- Miscellaneous -->
        <module name="EqualsHashCode"/>        <!-- If equals, then hashCode -->
        <module name="SimplifyBooleanExpression"/>
        <module name="SimplifyBooleanReturn"/>
        <module name="StringLiteralEquality"/>  <!-- Use .equals() not == -->
        <module name="ModifiedControlVariable"/>
        <module name="ArrayTypeStyle"/>
        <module name="UpperEll"/>               <!-- Use L not l for long -->
    </module>
</module>
```

### Run CheckStyle
```bash
# Maven
mvn checkstyle:check

# Gradle
gradle checkstyleMain checkstyleTest
```

---

## 3. SpotBugs — Java Bug Detection

### Setup (Maven)
```xml
<!-- pom.xml -->
<plugin>
    <groupId>com.github.spotbugs</groupId>
    <artifactId>spotbugs-maven-plugin</artifactId>
    <version>4.8.3.1</version>
    <dependencies>
        <!-- FindSecBugs for security-specific bugs -->
        <dependency>
            <groupId>com.h3xstream.findsecbugs</groupId>
            <artifactId>findsecbugs-plugin</artifactId>
            <version>1.13.0</version>
        </dependency>
    </dependencies>
    <configuration>
        <effort>Max</effort>
        <threshold>Medium</threshold>
        <xmlOutput>true</xmlOutput>
        <failOnError>true</failOnError>
        <plugins>
            <plugin>
                <groupId>com.h3xstream.findsecbugs</groupId>
                <artifactId>findsecbugs-plugin</artifactId>
            </plugin>
        </plugins>
        <excludeFilterFile>spotbugs-exclude.xml</excludeFilterFile>
    </configuration>
    <executions>
        <execution>
            <goals><goal>check</goal></goals>
        </execution>
    </executions>
</plugin>
```

### Setup (Gradle)
```groovy
// build.gradle
plugins {
    id 'com.github.spotbugs' version '6.0.8'
}

dependencies {
    spotbugsPlugins 'com.h3xstream.findsecbugs:findsecbugs-plugin:1.13.0'
}

spotbugs {
    effort = 'max'
    reportLevel = 'medium'
    excludeFilter = file("${rootDir}/spotbugs-exclude.xml")
}

tasks.withType(com.github.spotbugs.snom.SpotBugsTask) {
    reports {
        xml.required = true
        html.required = true
    }
}
```

### SpotBugs Bug Categories

| Category | Description | Examples |
|----------|-------------|---------|
| **CORRECTNESS** | Probable bugs | Null pointer dereference, infinite loops |
| **BAD_PRACTICE** | Violations of best practices | Missing hashCode with equals, Serializable issues |
| **STYLE** | Code style issues | Naming conventions, dead code |
| **PERFORMANCE** | Performance issues | Inefficient string concat, boxing/unboxing |
| **MALICIOUS_CODE** | Exposure to untrusted code | Public mutable static fields |
| **SECURITY** (FindSecBugs) | Security vulnerabilities | SQL injection, XSS, weak crypto, path traversal |

### FindSecBugs Security Detectors (Key)
| Detector | CWE | Description |
|----------|-----|-------------|
| `SQL_INJECTION` | CWE-89 | SQL injection via string concat |
| `XSS_SERVLET` | CWE-79 | Cross-site scripting |
| `PATH_TRAVERSAL` | CWE-22 | File path manipulation |
| `COMMAND_INJECTION` | CWE-78 | OS command injection |
| `WEAK_MESSAGE_DIGEST` | CWE-328 | MD5/SHA-1 for security |
| `HARD_CODE_PASSWORD` | CWE-798 | Hardcoded credentials |
| `INSECURE_COOKIE` | CWE-614 | Cookie without Secure flag |
| `UNVALIDATED_REDIRECT` | CWE-601 | Open redirect |
| `PREDICTABLE_RANDOM` | CWE-330 | java.util.Random for security |

### spotbugs-exclude.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<FindBugsFilter>
    <!-- Exclude generated code -->
    <Match>
        <Package name="~.*\.generated\..*"/>
    </Match>

    <!-- Exclude test classes from certain checks -->
    <Match>
        <Class name="~.*Test"/>
        <Bug category="STYLE"/>
    </Match>

    <!-- Exclude specific false positives (document reason) -->
    <!-- <Match>
        <Class name="com.example.MyClass"/>
        <Method name="myMethod"/>
        <Bug pattern="EI_EXPOSE_REP"/>
    </Match> -->
</FindBugsFilter>
```

### Run SpotBugs
```bash
# Maven
mvn spotbugs:check

# Gradle
gradle spotbugsMain spotbugsTest
```

---

## 4. Quality Gate Configuration

### Unified Quality Gate Matrix

```
┌─────────────────────────────────────────────────────────────────────┐
│                    QUALITY GATE — "Production Ready"                │
├──────────────────────┬──────────────────────────────────────────────┤
│  Metric              │  Threshold                                  │
├──────────────────────┼──────────────────────────────────────────────┤
│  ⬛ SonarCloud                                                      │
│  Coverage (new code) │  ≥ 80%                                      │
│  Duplication         │  ≤ 3%                                       │
│  Maintainability     │  A                                          │
│  Reliability         │  A                                          │
│  Security            │  A                                          │
│  Hotspots Reviewed   │  100%                                       │
├──────────────────────┼──────────────────────────────────────────────┤
│  ⬛ CheckStyle (Java)                                               │
│  Warnings            │  0                                          │
│  Errors              │  0                                          │
│  Method Length        │  ≤ 50 lines                                 │
│  Cyclomatic Complexity│ ≤ 10                                       │
│  Parameters          │  ≤ 5                                        │
├──────────────────────┼──────────────────────────────────────────────┤
│  ⬛ SpotBugs (Java)                                                │
│  Critical bugs       │  0                                          │
│  High bugs           │  0                                          │
│  FindSecBugs findings│  0                                          │
│  Medium bugs (max)   │  ≤ 5 (must have remediation plan)           │
├──────────────────────┼──────────────────────────────────────────────┤
│  ⬛ ESLint (JS/TS)                                                 │
│  Errors              │  0                                          │
│  Warnings            │  ≤ 10                                       │
│  Security rules      │  0 violations                               │
├──────────────────────┼──────────────────────────────────────────────┤
│  ⬛ Dependencies                                                   │
│  Critical CVEs       │  0                                          │
│  High CVEs           │  0                                          │
│  Outdated (major)    │  0 (within 1 major version)                 │
├──────────────────────┼──────────────────────────────────────────────┤
│  ⬛ Docker                                                         │
│  Image Critical CVEs │  0                                          │
│  Image High CVEs     │  0                                          │
│  Non-root user       │  Required                                   │
└──────────────────────┴──────────────────────────────────────────────┘
```

### CI/CD Integration (Full Pipeline)
```yaml
# .github/workflows/quality.yml
name: Quality Gate

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  # ─── JavaScript/TypeScript ─────────────
  quality-js:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm ci
      - run: npm run lint             # ESLint
      - run: npm run typecheck        # TypeScript
      - run: npm run test -- --coverage
      - name: SonarCloud
        uses: SonarSource/sonarcloud-github-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      - run: npm audit --audit-level=high

  # ─── Java ──────────────────────────────
  quality-java:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: actions/setup-java@v4
        with: { java-version: '21', distribution: 'temurin' }
      - run: mvn verify                           # Runs tests + coverage
      - run: mvn checkstyle:check                 # CheckStyle
      - run: mvn spotbugs:check                   # SpotBugs + FindSecBugs
      - run: mvn sonar:sonar -Dsonar.token=${{ secrets.SONAR_TOKEN }}
      - run: mvn dependency-check:check           # OWASP Dependency Check

  # ─── Quality Gate Decision ─────────────
  gate:
    needs: [quality-js, quality-java]
    runs-on: ubuntu-latest
    steps:
      - name: Check Quality Gate Status
        run: |
          echo "All quality checks passed ✅"
          echo "Ready for deployment"
```

---

## 5. ESLint Security & Quality (JS/TS)

```javascript
// eslint.config.js (flat config)
import eslintPluginSecurity from 'eslint-plugin-security';
import eslintPluginSonarjs from 'eslint-plugin-sonarjs';

export default [
  {
    plugins: {
      security: eslintPluginSecurity,
      sonarjs: eslintPluginSonarjs,
    },
    rules: {
      // Security
      'security/detect-object-injection': 'warn',
      'security/detect-non-literal-regexp': 'warn',
      'security/detect-unsafe-regex': 'error',
      'security/detect-buffer-noassert': 'error',
      'security/detect-eval-with-expression': 'error',
      'security/detect-no-csrf-before-method-override': 'error',
      'security/detect-possible-timing-attacks': 'warn',

      // SonarJS quality
      'sonarjs/cognitive-complexity': ['error', 15],
      'sonarjs/no-duplicate-string': ['error', 3],
      'sonarjs/no-identical-functions': 'error',
      'sonarjs/no-collapsible-if': 'error',
      'sonarjs/prefer-single-boolean-return': 'error',
      'sonarjs/no-redundant-jump': 'error',

      // Built-in quality
      'no-eval': 'error',
      'no-implied-eval': 'error',
      'no-new-func': 'error',
      'prefer-const': 'error',
      'no-var': 'error',
      'eqeqeq': ['error', 'always'],
      'complexity': ['error', 10],
      'max-depth': ['error', 4],
      'max-lines-per-function': ['error', { max: 50, skipBlankLines: true, skipComments: true }],
      'max-params': ['error', 4],
    },
  },
];
```

## Rules Integration
- **SOLID**: Method length, parameter count, complexity limits enforce SRP
- **Security**: FindSecBugs + ESLint security plugin catch OWASP Top 10 issues
- **ISO 27001**: Quality gates satisfy A.14 secure system development requirements
- **Dependencies**: OWASP Dependency Check and npm audit enforce dependency security
