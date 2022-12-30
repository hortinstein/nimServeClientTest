# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import asyncdispatch
import puppy
import flatty

when isMainModule:
  while true:
    try: 
      echo "get task"
      let task = fetch("http://127.0.0.1:8080/")
      let dec = task.fromFlatty(string)
      
      var body = ""      

      echo "returning spelled out version of: ", dec
      case dec
      of "1":
        body = "one"
      of "2":
        body = "two"
      of "3":
        body = "three"

      echo "post response: ", body
      let response = post(
          "http://127.0.0.1:8080",
          @[("Content-Type", "application/json")],
          toFlatty(body)
      )   
      echo "post response:", response.body
    except PuppyError:
      echo "error post/get"
      waitFor sleepAsync(1000)
      continue

   