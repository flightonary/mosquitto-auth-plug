# Choose one or more back-ends Allowed values are
#	BE_CDB
#	BE_MYSQL
#	BE_SQLITE
#	BE_REDIS
#	BE_POSTGRES

BACKENDS=-DBE_MYSQL #-DBE_POSTGRES -DBE_LDAP

BE_CFLAGS=
BE_LDFLAGS=

### MySQL ###
BE_CFLAGS += `mysql_config --cflags`
BE_LDFLAGS += `mysql_config --libs`

### PostgreSQL ###
#BE_CFLAGS += -I`pg_config --includedir`
#BE_LDFLAGS += -lpq

### cdb ###
CDBDIR=contrib/tinycdb-0.78
CDB=$(CDBDIR)/cdb
CDBINC=$(CDBDIR)/
CDBLIB=$(CDBDIR)/libcdb.a
BE_CFLAGS += -I$(CDBINC)/
BE_LDFLAGS += -L$(CDBDIR) -lcdb
BE_DEPS = $(CDBLIB)

### sqlite3
#BE_LDFLAGS += -lsqlite3

### redis ###
#BE_CFLAGS += -I/usr/local/include/hiredis
#BE_LDFLAGS += -L/usr/local/lib -lhiredis

### LDAP ###
#BE_LDFLAGS += -L/usr/lib -lldap -llber

MOSQUITTO_SRC=/Users/jpm/Auto/pubgit/MQTT/mosquitto/140/mosquitto/

OPENSSLDIR=/usr/local/stow/openssl-1.0.0c/
OSSLINC=-I$(OPENSSLDIR)/include
OSSLIBS=-L$(OPENSSLDIR)/lib -lcrypto 

OBJS=auth-plug.o base64.o pbkdf2-check.o log.o hash.o be-psk.o be-cdb.o be-mysql.o be-sqlite.o be-redis.o be-postgres.o be-ldap.o topic.o
CFLAGS = -I$(MOSQUITTO_SRC)/src/
CFLAGS += -I$(MOSQUITTO_SRC)/lib/
CFLAGS += -fPIC -Wall -Werror $(BACKENDS) $(BE_CFLAGS) -I$(MOSQ)/src -DDEBUG=1 $(OSSLINC)
BE_CFLAGS += -I/usr/include
LDFLAGS=$(BE_LDFLAGS) -lmosquitto $(OSSLIBS)
LDFLAGS += -L$(MOSQUITTO_SRC)/lib/
# LDFLAGS += -Wl,-rpath,$(../../../../pubgit/MQTT/mosquitto/lib) -lc
# LDFLAGS += -export-dynamic


all: auth-plug.so np 

auth-plug.so : $(OBJS) $(BE_DEPS)
	$(CC) -fPIC -shared $(OBJS) -o $@  $(OSSLIBS) $(BE_DEPS) $(LDFLAGS) 

be-redis.o: be-redis.c be-redis.h log.h hash.h Makefile
be-sqlite.o: be-sqlite.c be-sqlite.h Makefile
auth-plug.o: auth-plug.c be-cdb.h be-mysql.h be-sqlite.h Makefile
be-psk.o: be-psk.c be-psk.h Makefile
be-cdb.o: be-cdb.c be-cdb.h Makefile
be-mysql.o: be-mysql.c be-mysql.h Makefile
be-ldap.o: be-ldap.c be-ldap.h Makefile
be-sqlite.o: be-sqlite.c be-sqlite.h Makefile
pbkdf2-check.o: pbkdf2-check.c base64.h Makefile
base64.o: base64.c base64.h Makefile
log.o: log.c log.h Makefile
hash.o: hash.c hash.h uthash.h Makefile
be-postgres.o: be-postgres.c be-postgres.h Makefile
topic.o: topic.c topic.h Makefile

np: np.c base64.o
	$(CC) $(CFLAGS) $^ -o $@ $(OSSLIBS)

$(CDBLIB):
	(cd $(CDBDIR); make libcdb.a cdb )

pwdb.cdb: pwdb.in
	$(CDB) -c -m  pwdb.cdb pwdb.in
clean :
	rm -f *.o *.so np
	(cd contrib/tinycdb-0.78; make realclean )
