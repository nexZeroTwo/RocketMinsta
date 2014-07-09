QCC?=rmqcc
QCCOPTS?= -Werror -Wall -Wno-mundane -O3 -Ono-c -Ono-cs -flo
PK3ZIP?=7za
PK3ZIPOPTS?=a -tzip -mx=9
CD?=cd
DATE?=`date +%s`

pack: pack_progs pack_menu

pack_progs: build_progs
	$(PK3ZIP) $(PK3ZIPOPTS) base_progs-$(DATE).pk3 progs.dat csprogs.dat qcsrc
pack_menu: build_menu
	$(PK3ZIP) $(PK3ZIPOPTS) base_menu-$(DATE).pk3 menu.dat



build_all: build_menu build_client build_server

build_progs: build_client build_server
build_menu:
	$(CD) qcsrc/menu && $(QCC) $(QCCOPTS)


build_client:
	$(CD) qcsrc/client && $(QCC) $(QCCOPTS)
build_server:
	$(CD) qcsrc/server && $(QCC) $(QCCOPTS)


clean:
	$(RM) menu.dat progs.dat csprogs.dat menu.lno progs.lno csprogs.lno base_progs-*.pk3 base_menu-*.pk3
	find -iname '$(QCC).log' -exec $(RM) {} \;