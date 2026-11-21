# Maintainer: João V. Farias <beyondmagic@mail.ru>

pkgname=python-validity-elogind-dinit
pkgver=0.15
pkgrel=1
pkgdesc="elogind system-sleep hook for python-validity (dinit)"
arch=('any')
url="https://github.com/uunicorn/python-validity"
license=('GPL-2.0')
depends=('python-validity' 'open-fprintd' 'open-fprintd-dinit' 'python-validity-dinit' 'elogind' 'dinit')
makedepends=()
source=("python-validity.sh")
sha256sums=('4e8b3a789380ee0826b2ec5a1c189f6cf5f8beef2a98c2dd3948da7f7f4ba957')

package() {
    install -Dm755 "${srcdir}/python-validity.sh" \
        "${pkgdir}/etc/elogind/system-sleep/python-validity.sh"
}