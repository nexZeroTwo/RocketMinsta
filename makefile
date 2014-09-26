QCC?=rmqcc
QCCOPTS?= -Werror -Wall -Wno-mundane -O3 -Ono-c -Ono-cs -flo
PK3ZIP?=7za
PK3ZIPOPTS?=a -tzip -mx=9
CD?=cd
DATE?=`date +%s`

pack: pack_progs pack_menu

%.dat:
	$(CD) qcsrc/$(basename $@) && $(QCC) $(QCCOPTS)

.PHONY: pack_progs
pack_progs: base_progs.pk3
base_progs.pk3: progs.dat csprogs.dat
	$(PK3ZIP) $(PK3ZIPOPTS) base_progs.pk3 progs.dat csprogs.dat qcsrc
.PHONY: pack_menu
pack_menu: base_menu.pk3
base_menu.pk3: menu.dat
	$(PK3ZIP) $(PK3ZIPOPTS) base_menu.pk3 menu.dat

build_all: build_menu build_client build_server

build_progs: build_client build_server


clean:
	$(RM) menu.dat progs.dat csprogs.dat menu.lno progs.lno csprogs.lno base_progs.pk3 base_menu.pk3
	find -iname '*.log' -exec $(RM) {} \;