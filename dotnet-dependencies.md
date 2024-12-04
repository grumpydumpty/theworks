# .NET 8 Linux package dependencies

.NET 8 has several dependencies that must be satisfied to run .NET apps. The commands to install these libraries are listed for multiple Linux distributions.

Feel free to contribute packages for distributions not (yet) listed in this document, including ones not supported by the .NET Team.

Tips:

- [runtime-deps container images](https://github.com/dotnet/dotnet-docker/tree/main/src/runtime-deps) installs these same packages. You can look at those dockerfiles.
- [pkgs.org](https://pkgs.org/) is a useful site for searching for packages, to find the one for your distribution.

## Packages

.NET depends on the following packages.

- [GNU C Library (glibc)](https://www.gnu.org/software/libc/libc.html)
- [GNU C++ Library](https://gcc.gnu.org/onlinedocs/libstdc++/)
- [GCC low-level runtime library](https://gcc.gnu.org/onlinedocs/gccint/Libgcc.html)
- [ICU](http://site.icu-project.org/)
- [Kerberos](http://web.mit.edu/kerberos/)
- [Open SSL](https://www.openssl.org/)
- [zlib compression library](https://www.zlib.net/)

You do not need to install ICU if you [enable globalization invariant mode](https://github.com/dotnet/runtime/blob/main/docs/design/features/globalization-invariant-mode.md#enabling-the-invariant-mode).

If your app relies on `https` endpoints, you'll also need to install `ca-certificates`.

## Alpine 3.18 - 3.19

```bash
sudo apk add \
    libgcc \
    libssl3 \
    libstdc++ \
    zlib
```

## Debian 12 "Bookworm"

```bash
sudo apt-get update \
    && sudo apt-get install -y --no-install-recommends \
     libc6 \
     libgcc-s1 \
     libicu72 \
     libssl3 \
     libstdc++6 \
     tzdata \
     zlib1g \
```

## Ubuntu 24.04 "Noble"

```bash
sudo apt-get update \
    && sudo apt-get install -y --no-install-recommends \
    libc6 \
    libgcc-s1 \
    libicu74 \
    libssl3 \
    libstdc++6 \
    zlib1g 
```


# .NET 9 Required Packages

Various packages must be installed to run .NET apps and the .NET SDK. This is handled automatically if .NET is [installed through archive packages](../../linux.md).

This file is generated from [os-packages.json](os-packages.json).

## Package Overview

The following table lists required packages, including the scenarios by which they are needed.

Id              | Name      | Required scenarios | Notes
--------------- | --------- | ------------- | ------------------------------
[libc][0]       | C Library | All           | https://github.com/dotnet/core/blob/main/release-notes/9.0/supported-os.md#linux-compatibility<br>https://www.gnu.org/software/libc/libc.html<br>https://musl.libc.org/
[libgcc][1]     | GCC low-level runtime library | All | https://gcc.gnu.org/onlinedocs/gccint/Libgcc.html
[ca-certificates][2] | CA Certificates | Https | https://www.redhat.com/sysadmin/ca-certificates-cli
[openssl][3]    | OpenSSL   | Https<br>Cryptography | Minimum required version 1.1.1<br>https://www.openssl.org/
[libstdc++][4]  | C++ Library | Runtime     | https://gcc.gnu.org/onlinedocs/libstdc++/
[libicu][5]     | ICU       | Globalization | https://icu.unicode.org<br>https://github.com/dotnet/runtime/blob/main/docs/design/features/globalization-invariant-mode.md
[tzdata][6]     | tz database | Globalization | https://data.iana.org/time-zones/tz-link.html
[krb5][7]       | Kerberos  | Kerberos      | https://web.mit.edu/kerberos

[0]: https://pkgs.org/search/?q=libc
[1]: https://pkgs.org/search/?q=libgcc
[2]: https://pkgs.org/search/?q=ca-certificates
[3]: https://pkgs.org/search/?q=openssl
[4]: https://pkgs.org/search/?q=libstdc++
[5]: https://pkgs.org/search/?q=libicu
[6]: https://pkgs.org/search/?q=tzdata
[7]: https://pkgs.org/search/?q=krb5

## Alpine

### Alpine 3.20

```bash
sudo apk add \
    ca-certificates \
    icu-data-full \
    icu-libs \
    krb5 \
    libgcc \
    libssl3 \
    libstdc++ \
    tzdata
```

## Debian

### Debian 12 (Bookworm)

```bash
sudo apt-get update && \
sudo apt-get install -y \
    ca-certificates \
    libc6 \
    libgcc-s1 \
    libgssapi-krb5-2 \
    libicu72 \
    libssl3 \
    libstdc++6 \
    tzdata
```

## RHEL

### RHEL 9

```bash
sudo dnf install -y \
    ca-certificates \
    glibc \
    krb5-libs \
    libgcc \
    libicu \
    libstdc++ \
    openssl-libs \
    tzdata
```

## Ubuntu

### Ubuntu 24.04 (Noble Numbat)

```bash
sudo apt-get update && \
sudo apt-get install -y \
    ca-certificates \
    libc6 \
    libgcc-s1 \
    libgssapi-krb5-2 \
    libicu74 \
    libssl3t64 \
    libstdc++6 \
    tzdata
```

## References

- https://github.com/dotnet/core/blob/main/release-notes/8.0/linux-packages.md
- https://github.com/dotnet/core/blob/main/release-notes/9.0/os-packages.md
- https://github.com/dotnet/runtime/blob/main/docs/design/features/globalization-invariant-mode.md#enabling-the-invariant-mode

