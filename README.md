#Arkopter
Here is my [humble implementation] of the challenge:   

A note: I underestimated getting my environment setup and part way through it got hosed from an update.  I decided to write everything untested/unrun code to meet the deadline.  After which I could go back, fix my environment and test the workers/bg-queue. My typical approach would be heavy on the test driven and serious QA side of things. 

It uses asynchronous background queues to process everything.  Initially I used PostgreSQL to store everything but migrated to PostgreSQL and Redis.  PostgreSQL was used to store object data and Redis for background processing of queues; I also used Redis to store real-time inventory numbers in a Redis hash and transitioned to Redis Semaphores to lock the inventory on a hash key level when updating the inventory.  I did test out Redis::Objects and you will see some of my lock use it, mixed with models (like StockItem for example) but I was transitioning to Redis Semaphores entirely.  Locking also occurs on rows being modified in PSQL via the ActiveRecord transaction mechanism. 

Initially I synced inventory numbers between the psql and redis which I thought would be useful, but decided it was clunky, in the end I gave the application it’s own connection to Redis along with the background processor to get inventory numbers.  However, at present the application currently reconciles PSQL and Redis inventory numbers. 

##Models
All the lifting is handled by the models and the ninjas (which is what I call the background workers).  The application does what it can to get data in the right place within PostgreSQL so that when a job is sent Sidekiq for processing it can seek an id and pull in whatever it needs to get the costly jobs done.  The point was to reduce serialization of data from app to Redis. SO for example, pick-n-pull of products to make an order happens app side for now, put everything else happen via concurrent queues.

- StockItem: these are SKUs, product types. 
- Product: inventory of StockItems
- QuadArkopter: modeled because I wanted to run this with limited quadcopters to test the queue processing.  Delivery time is modeled as well with seconds for sleep
- Order: aggregate Products once they 
- User: added user that makes orders because I wanted to model real traffic.

##Ninjas/Workers
There are 5 ninjas or background job queues in the app/ninjas directory which transition Orders and Products through statuses of "warehoused","processing", "on-arkopter", "en-route", "delivered", "canceled" and helicopters through statuses of "ready", "reserved", "loaded-up", "en-route", and "in-redeployment"
- FulfillmentNinja: get orders packed up onto helicopters, procures the helicopter, if there are no that are “ready” this is the queue that will blocks until copters are redeployed and ready. It marks orders and product all from on board to en-route. Then sends to CargoNinja for delivery
- AbacusNinja: handles async requests for inventory availability 
- TerminatorNinja: cancels orders, redeploys helicopters to take more orders, releases product back to inventory db, etc.
- CargoNinja: delivery happens here, and it is models to actually sleep for some travel time and if status changes during delivery is 
- PigeonNinja: I don’t think I got to that one, it was going to be for an async public activity feed for the “reporting back”

##Validations
I implemented none, but obviously in the wild data would be scrubbed. 

##Needed
- UI
- Deployment
- API access
- Run the freakin’ queues and code to ensure it works. 

[humble implementation]:https://github.com/cocoonventures/arkopter
