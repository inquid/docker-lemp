use admin
db.createUser(
  {
    user: "admin",
    pwd: "1234567890",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)
