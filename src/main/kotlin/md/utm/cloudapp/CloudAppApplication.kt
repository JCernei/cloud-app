package md.utm.cloudapp

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class CloudAppApplication

fun main(args: Array<String>) {
    runApplication<CloudAppApplication>(*args)
}
