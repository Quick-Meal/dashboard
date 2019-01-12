package main

import (
	"github.com/boltdb/bolt"
	"github.com/gin-gonic/gin"
	"log"
)

var db *bolt.DB

func main() {
	// start bolt
	db, err := bolt.Open("user.db", 0600, nil)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()
	
	r := gin.Default()
	r.Static("/", "./frontend/")
	r.POST("/post", validateUser)
	r.Run() // listen and serve on 0.0.0.0:8080
}

func validateUser(c *gin.Context) {
	id := c.PostForm("id")
	password := c.PostForm("password")

	err := db.View(func(tx *bolt.Tx) error {
		b := tx.Bucket([]byte("user"))
		v := b.Get([]byte(id))
		if password == string(v) {
			c.JSON(200, gin.H{
				"message": "correct password",
			})
		} else {
			c.JSON(401, gin.H{
				"message": "wrong password",
			})
		}

		return nil
	})
	if err != nil {
		c.JSON(500, gin.H{
			"message": "internal server error"
		})
	}


}
