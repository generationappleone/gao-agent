---
name: XML (Extensible Markup Language)
description: Skill for writing well-structured XML documents — covering XML 1.0/1.1 specification, elements, attributes, namespaces, DTD, XSD Schema, XSLT, XPath, CDATA, processing instructions, and common patterns (Maven POM, Android, Spring, SVG, RSS/Atom, SOAP, web.xml).
---

# XML (Extensible Markup Language) Skill

## Overview
XML is a markup language for encoding documents in a human- and machine-readable format. This skill follows the **W3C XML 1.0** specification (global standard).

**References**:
- [W3C XML 1.0 Specification](https://www.w3.org/TR/xml/)
- [W3C XML Schema (XSD)](https://www.w3.org/TR/xmlschema-1/)
- [W3C Namespaces in XML](https://www.w3.org/TR/xml-names/)

## XML Declaration
```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>

<!-- ✅ Always include XML declaration as first line -->
<!-- ✅ Always use UTF-8 encoding -->
<!-- ✅ version is required, encoding and standalone are optional -->
```

## Core Syntax

### Elements
```xml
<!-- Self-closing element -->
<element/>
<element />

<!-- Element with content -->
<element>Text content</element>

<!-- Nested elements -->
<parent>
  <child>Value</child>
  <child>Value</child>
</parent>

<!-- Mixed content -->
<paragraph>This is <bold>important</bold> text.</paragraph>

<!-- ✅ Element names are case-sensitive -->
<!-- ✅ Use lowercase or camelCase consistently -->
<!-- ❌ Names cannot start with numbers or xml (reserved) -->
```

### Attributes
```xml
<element attribute="value"/>
<user id="1" name="John" active="true"/>

<!-- ✅ Attribute values MUST be quoted (single or double) -->
<!-- ✅ Use attributes for metadata, elements for data -->
<!-- ❌ No duplicate attributes on same element -->

<!-- When to use attributes vs elements -->
<user id="1">                    <!-- id as attribute (metadata) -->
  <name>John Doe</name>          <!-- name as element (data) -->
  <email>john@example.com</email>
</user>
```

### Comments
```xml
<!-- This is a comment -->

<!--
  Multi-line comment
  spanning several lines
-->

<!-- ❌ Comments cannot contain double dashes -- inside -->
<!-- ❌ Comments cannot be nested -->
```

### CDATA Sections
```xml
<!-- CDATA: raw text without escaping -->
<script>
<![CDATA[
  if (a < b && c > d) {
    console.log("No need to escape < > & here");
  }
]]>
</script>

<!-- ✅ Use CDATA for code, scripts, or text with special characters -->
```

### Special Characters (Entity References)
```xml
&lt;     <!-- < (less than) -->
&gt;     <!-- > (greater than) -->
&amp;    <!-- & (ampersand) -->
&quot;   <!-- " (double quote) -->
&apos;   <!-- ' (apostrophe) -->

<!-- Numeric character references -->
&#169;   <!-- © (copyright) -->
&#8364;  <!-- € (euro) -->
&#x20AC; <!-- € (euro, hex) -->
```

### Processing Instructions
```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="transform.xsl"?>
<?xml-model href="schema.xsd" type="application/xml"?>
```

## Namespaces
```xml
<!-- Default namespace -->
<root xmlns="http://example.com/default">
  <child>Inherits default namespace</child>
</root>

<!-- Prefixed namespace -->
<root xmlns:app="http://example.com/app"
      xmlns:db="http://example.com/db">
  <app:config>
    <app:setting name="timeout">30</app:setting>
  </app:config>
  <db:connection>
    <db:host>localhost</db:host>
  </db:connection>
</root>

<!-- ✅ Use meaningful namespace prefixes -->
<!-- ✅ Namespace URI must be unique (doesn't need to resolve) -->
```

## XML Schema (XSD)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"
           targetNamespace="http://example.com/app"
           xmlns:app="http://example.com/app"
           elementFormDefault="qualified">

  <!-- Simple type -->
  <xs:simpleType name="EmailType">
    <xs:restriction base="xs:string">
      <xs:pattern value="[^@]+@[^@]+\.[^@]+"/>
    </xs:restriction>
  </xs:simpleType>

  <!-- Complex type -->
  <xs:complexType name="UserType">
    <xs:sequence>
      <xs:element name="name" type="xs:string"/>
      <xs:element name="email" type="app:EmailType"/>
      <xs:element name="age" type="xs:positiveInteger" minOccurs="0"/>
    </xs:sequence>
    <xs:attribute name="id" type="xs:positiveInteger" use="required"/>
    <xs:attribute name="active" type="xs:boolean" default="true"/>
  </xs:complexType>

  <!-- Root element -->
  <xs:element name="users">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="user" type="app:UserType"
                    minOccurs="0" maxOccurs="unbounded"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>
```

### XSD Data Types
```xml
<!-- String types -->
xs:string, xs:normalizedString, xs:token

<!-- Numeric types -->
xs:integer, xs:positiveInteger, xs:negativeInteger
xs:int, xs:long, xs:short, xs:byte
xs:decimal, xs:float, xs:double

<!-- Date/Time types -->
xs:date, xs:time, xs:dateTime
xs:duration, xs:gYear, xs:gMonth

<!-- Other types -->
xs:boolean, xs:anyURI, xs:base64Binary
xs:ID, xs:IDREF
```

## Document Type Definition (DTD)
```xml
<!-- Internal DTD -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE users [
  <!ELEMENT users (user*)>
  <!ELEMENT user (name, email, age?)>
  <!ATTLIST user id CDATA #REQUIRED>
  <!ATTLIST user active (true|false) "true">
  <!ELEMENT name (#PCDATA)>
  <!ELEMENT email (#PCDATA)>
  <!ELEMENT age (#PCDATA)>
]>

<!-- External DTD -->
<!DOCTYPE users SYSTEM "users.dtd">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
```

## Common XML Patterns

### Maven POM (pom.xml)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.example</groupId>
  <artifactId>myapp</artifactId>
  <version>1.0.0</version>
  <packaging>jar</packaging>

  <properties>
    <java.version>21</java.version>
    <maven.compiler.source>${java.version}</maven.compiler.source>
    <maven.compiler.target>${java.version}</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
      <version>3.3.0</version>
    </dependency>
    <dependency>
      <groupId>org.junit.jupiter</groupId>
      <artifactId>junit-jupiter</artifactId>
      <version>5.10.0</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
</project>
```

### Spring Configuration
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="
         http://www.springframework.org/schema/beans
         http://www.springframework.org/schema/beans/spring-beans.xsd
         http://www.springframework.org/schema/context
         http://www.springframework.org/schema/context/spring-context.xsd">

  <context:component-scan base-package="com.example"/>

  <bean id="dataSource" class="com.zaxxer.hikari.HikariDataSource">
    <property name="jdbcUrl" value="${db.url}"/>
    <property name="username" value="${db.user}"/>
    <property name="password" value="${db.password}"/>
  </bean>
</beans>
```

### Android Layout
```xml
<?xml version="1.0" encoding="UTF-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="16dp">

  <TextView
      android:id="@+id/titleText"
      android:layout_width="wrap_content"
      android:layout_height="wrap_content"
      android:text="@string/app_name"
      android:textSize="24sp"/>

  <EditText
      android:id="@+id/inputField"
      android:layout_width="match_parent"
      android:layout_height="wrap_content"
      android:hint="@string/hint_input"
      android:inputType="text"/>

  <Button
      android:id="@+id/submitButton"
      android:layout_width="match_parent"
      android:layout_height="wrap_content"
      android:text="@string/btn_submit"/>
</LinearLayout>
```

### AndroidManifest.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          package="com.example.myapp">

  <uses-permission android:name="android.permission.INTERNET"/>

  <application
      android:allowBackup="true"
      android:icon="@mipmap/ic_launcher"
      android:label="@string/app_name"
      android:theme="@style/AppTheme">
    <activity
        android:name=".MainActivity"
        android:exported="true">
      <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
      </intent-filter>
    </activity>
  </application>
</manifest>
```

### web.xml (Java Servlet)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee
         https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
         version="6.0">

  <display-name>MyApp</display-name>

  <servlet>
    <servlet-name>dispatcher</servlet-name>
    <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
    <load-on-startup>1</load-on-startup>
  </servlet>

  <servlet-mapping>
    <servlet-name>dispatcher</servlet-name>
    <url-pattern>/</url-pattern>
  </servlet-mapping>

  <error-page>
    <error-code>404</error-code>
    <location>/WEB-INF/views/error/404.jsp</location>
  </error-page>
</web-app>
```

### SVG
```xml
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg"
     viewBox="0 0 100 100" width="100" height="100">
  <circle cx="50" cy="50" r="40" fill="#3b82f6" stroke="#1d4ed8" stroke-width="2"/>
  <text x="50" y="55" text-anchor="middle" fill="white" font-size="20">OK</text>
</svg>
```

### RSS Feed
```xml
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>My Blog</title>
    <link>https://example.com</link>
    <description>Latest posts</description>
    <atom:link href="https://example.com/rss.xml" rel="self" type="application/rss+xml"/>
    <item>
      <title>First Post</title>
      <link>https://example.com/post/1</link>
      <description>Post summary here</description>
      <pubDate>Wed, 19 Feb 2026 08:00:00 GMT</pubDate>
      <guid>https://example.com/post/1</guid>
    </item>
  </channel>
</rss>
```

### .NET Configuration (App.config / Web.config)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <appSettings>
    <add key="AppName" value="MyApp"/>
    <add key="MaxRetries" value="3"/>
  </appSettings>
  <connectionStrings>
    <add name="DefaultConnection"
         connectionString="Server=localhost;Database=mydb;Trusted_Connection=True;"
         providerName="System.Data.SqlClient"/>
  </connectionStrings>
</configuration>
```

### .csproj (.NET Project)
```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.EntityFrameworkCore" Version="8.0.0"/>
    <PackageReference Include="Serilog" Version="3.1.0"/>
  </ItemGroup>
</Project>
```

## XPath Basics
```xpath
/root/child           <!-- Absolute path -->
//element             <!-- Any depth -->
/root/child/@attr     <!-- Attribute -->
/root/child[1]        <!-- First child -->
/root/child[last()]   <!-- Last child -->
/root/child[@id='1']  <!-- Filter by attribute -->
//element[text()='x'] <!-- Filter by text -->
/root/child/*         <!-- All children -->
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **XML declaration** | Always include `<?xml version="1.0" encoding="UTF-8"?>` |
| **UTF-8 encoding** | Always use UTF-8 |
| **2-space indent** | Standard indentation for readability |
| **Self-close empty** | Use `<element/>` for empty elements |
| **Escape entities** | Always escape `<`, `>`, `&`, `"`, `'` |
| **Use namespaces** | Avoid name collisions in complex documents |
| **Schema validation** | Validate against XSD or DTD |
| **Attributes for metadata** | Elements for data, attributes for metadata |
| **Meaningful names** | Use descriptive, consistent element/attribute names |
| **Case consistency** | XML is case-sensitive — be consistent |

## Validation
```bash
# xmllint (libxml2)
xmllint --noout document.xml               # Well-formedness
xmllint --noout --schema schema.xsd doc.xml # Schema validation
xmllint --format document.xml               # Pretty print
```

## Rules Integration
- **Security**: Disable external entity processing (XXE prevention), validate input
- **Encoding**: Always UTF-8, declare in XML prolog
- **Validation**: Always validate against XSD schema in production
- **Namespaces**: Use proper namespace URIs for interoperability
- **Version Control**: XML diffs work best with consistent formatting
