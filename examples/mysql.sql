USE test;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
	id INTEGER AUTO_INCREMENT,
	username VARCHAR(25) NOT NULL,
	pw VARCHAR(128) NOT NULL,
	super INT(1) NOT NULL DEFAULT 0,
	PRIMARY KEY (id)
  );

CREATE UNIQUE INDEX users_username ON users (username);

-- password is the same as the username.
INSERT INTO users (username, pw) VALUES ('jjolie', 'PBKDF2$sha256$901$C3XYr4cr1HVQa9hrVbQHIUa45PRvp9Pu$C0UY8viPQNKjybdCkszXRmF9orO89YJU');
INSERT INTO users (username, pw) VALUES ('a', 'PBKDF2$sha256$901$nFrdsEeUPsMX6i0rP2O/otpBXRgxPxeW$WRDSe50a0I5F+ieETHPvkfg7eSdvzh72');
INSERT INTO users (username, pw) VALUES ('1234', 'PBKDF2$sha256$901$UBiXAe28rpyAuoFyIbslAND/+1OZXygA$EO5WQ2mivuomhNuPc6tIlw1KO7ZptxJl');
INSERT INTO users (username, pw, super)
	VALUES ('su1',
	'PBKDF2$sha256$901$7xuAbrbtqSFqfbyIsjv606PqmI3N72pF$8d9KHf6sZKb1LpJOl8Mzyzlw6M3sJrOo',
	1);
INSERT INTO users (username, pw, super)
	VALUES ('S1',
	'PBKDF2$sha256$901$V5p8pPW0hB6AvrWSySAuGPBwEvImHt6N$63Um+i3MASZgQ+r7g1o8mOmQomqKXfMT',
	1);
INSERT INTO users (username, pw, super)
	VALUES ('m1',
	'PBKDF2$sha256$901$PHJ0Hq4+DiC4SWwdTOGUQMOR3PtWLnKs$jMG157pRvQWnKgAFHvZf80ln/OYj/Y6I',
	0);
-- PSK
INSERT INTO users (username, pw, super)
	VALUES ('ps1',
	'deaddead',
	0);

DROP TABLE IF EXISTS acls;

CREATE TABLE acls (
	id INTEGER AUTO_INCREMENT,
	username VARCHAR(25) NOT NULL,
	topic VARCHAR(256) NOT NULL,
	rw INTEGER(1) NOT NULL DEFAULT 1,	-- 0: none, 1: read, 2: write, 3: read,write
	PRIMARY KEY (id)
	);
CREATE UNIQUE INDEX acls_user_topic ON acls (username, topic(228));

INSERT INTO acls (username, topic, rw) VALUES ('jjolie', 'loc/%u', 1);
INSERT INTO acls (username, topic, rw) VALUES ('jjolie', 'loc/ro', 1);
INSERT INTO acls (username, topic, rw) VALUES ('jjolie', 'loc/rw', 3);
INSERT INTO acls (username, topic, rw) VALUES ('jjolie', '$SYS/something', 1);
INSERT INTO acls (username, topic, rw) VALUES ('a', 'loc/test/#', 1);
INSERT INTO acls (username, topic, rw) VALUES ('a', '$SYS/broker/log/+', 1);

INSERT INTO acls (username, topic, rw) VALUES ('jjolie', 'msg', 1);
INSERT INTO acls (username, topic, rw) VALUES ('a', 'msg', 2);

INSERT INTO acls (username, topic, rw) VALUES ('su1', 'mega/secret', 1);
INSERT INTO acls (username, topic, rw) VALUES ('nop', 'mega/secret', 1);

INSERT INTO acls (username, topic, rw) VALUES ('jog', 'loc/#', 1);
INSERT INTO acls (username, topic, rw) VALUES ('m1', 'loc/#', 1);

INSERT INTO acls (username, topic, rw) VALUES ('ps1', 'x', 1);
INSERT INTO acls (username, topic, rw) VALUES ('ps1', 'blabla/%c/priv/#', 1);
