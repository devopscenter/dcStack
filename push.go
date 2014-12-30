package main

import (
    "fmt"
    "gopkg.in/yaml.v1"
    "io/ioutil"
    "os"
)

type Config struct {
    Version string
    Images []string
}

func main() {
    const filename = "push.yml"
    var config Config
    source, err := ioutil.ReadFile(filename)
    if err != nil {
        panic(err)
    }
    err = yaml.Unmarshal(source, &config)
    if err != nil {
        panic(err)
    }
    for _,element := range config.Images {
        fmt.Printf("Value: %#v\n", element)
    }
}
