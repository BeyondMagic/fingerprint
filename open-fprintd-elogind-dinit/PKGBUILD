# Maintainer: João V. Farias <beyondmagic@mail.ru>

pkgname=open-fprintd-elogind-dinit
pkgver=0.7
pkgrel=1
pkgdesc="elogind system-sleep hook for open-fprintd (dinit)"
arch=('any')
url="https://github.com/uunicorn/open-fprintd"
license=('GPL-2.0') 
depends=('open-fprintd' 'elogind' 'dinit')
makedepends=()
source=("open-fprintd.sh")
sha256sums=('a956503cca6adc3692c44b5c0d6469da80623187d1b09dc75d30c3347e0562d0')

package() {
    install -Dm755 "${srcdir}/open-fprintd.sh" \
        "${pkgdir}/etc/elogind/system-sleep/open-fprintd.sh"
}