import unittest
import asyncdispatch, asynchttpserver, uri, urlly, zippy, flatty

type 
  Task* = ref object
    req*: string # Request data for the task
    resp*: string # Response data for the task

# Create a new task object
proc newTask*(req: string): Task =
  Task(req: req, resp: "")

proc serveTask(t: Task, server: AsyncHttpServer) =
  # Define a nested proc that will handle incoming requests
  proc cbget(req: Request, t: Task,server: AsyncHttpServer) {.async.} =
    # Use a case statement to handle different request methods
    case req.reqMethod
    # If the request method is an HTTP GET
    of HttpGet:
      echo "got a get request"
      # If the request URL path is "/"
      if req.url.path == "/":
        # Send the task data in the response
        await req.respond(Http200, toFlatty(t.req))
        echo "sent task"
        return
    # If the request method is neither an HTTP GET nor an HTTP POST
    else:
      # Discard the request
      discard
    # Send an HTTP 404 response with the message "Not found."
    await req.respond(Http404, "Not found.")
  # Define a nested proc that will handle incoming requests
  proc cbpost(req: Request, t: Task,server: AsyncHttpServer) {.async.} =
    # Use a case statement to handle different request methods
    case req.reqMethod
    # If the request method is an HTTP POST
    of HttpPost:
      echo "got a post request"
      # If the request URL path is "/"
      if req.url.path == "/":
        # Get the response data from the request body
        let resp = req.body.fromFlatty(string)
        t.resp = resp
        echo "ack post request"
        await req.respond(Http200, "ok")
        
        return
    # If the request method is neither an HTTP GET nor an HTTP POST
    else:
      # Discard the request
      discard
    # Send an HTTP 404 response with the message "Not found."
    await req.respond(Http404, "Not found.")

  # If the server is ready to accept requests
  if server.shouldAcceptRequest():
    echo "waiting for the get request"
    waitFor server.acceptRequest(
      proc (req: Request): Future[void] = cbget(req, t,server)
    )
   
    # Wait for the server to accept a request and pass it to the cb proc
    echo "waiting for the post request"
    waitFor server.acceptRequest(
      proc (req: Request): Future[void] = cbpost(req, t,server)
    )

    ######################
    # This fixed my code...but is there a better way to do it?
    ######################
    #waitFor sleepAsync(1000)
 
suite "tests the creation of a task queue":
  let t1 = newTask("1")
  let t2 = newTask("2")
  let t3 = newTask("3")
  let server = newAsyncHttpServer()
  server.listen(Port(8080))
  
  test "test task1":
    serveTask(t1,server)
    echo "recieved resp:", t1.resp
    assert (t1.resp == "one")

  test "test task2":
    serveTask(t2,server)
    echo "recieved resp: ",t2.resp
    assert (t2.resp == "two")

  test "test task3":
    serveTask(t3,server)
    echo "recieved resp: ",t3.resp
    assert (t3.resp == "three")
