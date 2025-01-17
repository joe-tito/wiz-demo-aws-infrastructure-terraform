use admin
db.createUser({ user: "MONGO_USER", pwd: "MONGO_PASSWORD", roles: ["userAdminAnyDatabase"] })