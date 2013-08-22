DROP TABLE IF EXISTS users;

CREATE TABLE users (
	id INTEGER AUTO_INCREMENT,
	username VARCHAR(25) NOT NULL,
	pw VARCHAR(128) NOT NULL,
	super INT(1) NOT NULL DEFAULT 0,
	PRIMARY KEY (id)
  );

CREATE UNIQUE INDEX users_username ON users (username);

INSERT INTO users (username, pw) VALUES ('jjolie', 'PBKDF2$sha256$901$x8mf3JIFTUFU9C23$Mid2xcgTrKBfBdye6W/4hE3GKeksu00+');
INSERT INTO users (username, pw) VALUES ('a', 'PBKDF2$sha256$901$BWj9zYQlAPtZDtxB$/tIBbTQhlzSOFF0AFFD9HYZA5WmjowVv');
INSERT INTO users (username, pw, super)
	VALUES ('S1',
	'PBKDF2$sha256$901$chEZ4HcSmKtlV0kf$yRh2N62uq6cHoAB6FIrxIN2iihYqNIJp',
	1);

DROP TABLE IF EXISTS acls;

CREATE TABLE acls (
	id INTEGER AUTO_INCREMENT,
	username VARCHAR(25) NOT NULL,
	topic VARCHAR(256) NOT NULL,
	rw INTEGER(1) NOT NULL DEFAULT 1,	-- FIXME: unused atm
	PRIMARY KEY (id)
	);
CREATE UNIQUE INDEX acls_user_topic ON acls (username, topic);

INSERT INTO acls (username, topic) VALUES ('jjolie', 'loc/jjolie');
INSERT INTO acls (username, topic) VALUES ('jjolie', '$SYS/something');
INSERT INTO acls (username, topic) VALUES ('a', 'loc/test/#');
INSERT INTO acls (username, topic) VALUES ('a', '$SYS/broker/log/+');
INSERT INTO acls (username, topic) VALUES ('S1', 'mega/secret');
INSERT INTO acls (username, topic) VALUES ('nop', 'mega/secret');
