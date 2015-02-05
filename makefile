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
base_progs.pk3: server.dat client.dat
	$(PK3ZIP) $(PK3ZIPOPTS) base_progs.pk3 server.dat client.dat qcsrc
.PHONY: pack_menu
pack_menu: base_menu.pk3
base_menu.pk3: menu.dat
	$(PK3ZIP) $(PK3ZIPOPTS) base_menu.pk3 menu.dat

clean:
	$(RM) menu.dat server.dat client.dat menu.lno server.lno client.lno base_progs.pk3 base_menu.pk3
	find -iname '*.log' -exec $(RM) {} \;