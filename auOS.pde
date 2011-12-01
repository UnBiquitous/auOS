#include <aJSON.h>


class uOS{
   private:
     aJsonObject* (* handler ) (aJsonObject* request);
     aJsonObject* driver;
   public:
     uOS(){
        //Destroy
     }
     ~uOS(){
        //Build
     }
     char* receive(char *message){
       aJsonObject* request = aJson.parse(message);
       aJsonObject* type = aJson.getObjectItem(request, "type");
       aJsonObject* response = NULL;
       String SCR("SERVICE_CALL_REQUEST");
       if (SCR.equalsIgnoreCase(type->valuestring)){
         Serial.println("Request Received");
         String DD_NAME("br.unb.unbiquitous.ubiquitos.driver.DeviceDriver");
         aJsonObject* driver = aJson.getObjectItem(request, "driver");
         if (DD_NAME.equalsIgnoreCase(driver->valuestring)){
           Serial.println("DeviceDriverCall");
           response = handleDeviceDriver(request);
         } else{
           Serial.println("OtherDeviceCall");
           response = handler(request);
         }
       
       }
       aJson.deleteItem(request);
       if (response != NULL){
         char * ret = aJson.print(response);
         aJson.deleteItem(response);
         return ret;
       }
       return NULL;
     }
     aJsonObject* handleDeviceDriver(aJsonObject* request){
       String LIST_DRRIVER("listDrivers");
       aJsonObject* service = aJson.getObjectItem(request, "service");
       if (LIST_DRRIVER.equalsIgnoreCase(service->valuestring)){
           Serial.println("listDrivers");
           aJsonObject *root = aJson.createObject();
           aJson.addStringToObject(root,"type","SERVICE_CALL_RESPONSE");
           
           aJsonObject *respData = aJson.createObject();
           aJson.addItemToObject(root, "responseData", respData);
           aJsonObject *driverList = aJson.createObject();
                      
           aJsonObject *deviceDriver = aJson.createObject();
           
           aJson.addItemToObject(driverList,"1",deviceDriver);
           
           aJson.addStringToObject(deviceDriver,"name","br.unb.unbiquitous.ubiquitos.driver.DeviceDriver");
//          
           aJsonObject *services = aJson.createArray();
           aJson.addItemToObject(deviceDriver,"services",services);
           
//           aJsonObject *handShake     = aJson.createObject();
//           aJson.addStringToObject(handShake,"name","handshake");
//           aJson.addItemToArray(services,handShake);
//           aJsonObject *authenticate  = aJson.createObject();
//           aJson.addStringToObject(authenticate,"name","authenticate");
//           aJson.addItemToArray(services,authenticate);
//           aJsonObject *listDrivers   = aJson.createObject();
//           aJson.addStringToObject(listDrivers,"name","listDrivers");
//           aJson.addItemToArray(services,listDrivers);
//           aJsonObject *goodBye       = aJson.createObject();
//           aJson.addStringToObject(goodBye,"name","goodBye");
//           aJson.addItemToArray(services,goodBye);
//           
//           aJson.addItemToObject(driverList,"2",driver);
           aJson.addItemToObject(respData,"driverList",driverList);
           
           return root;
       }
       return NULL;
     }
     char* addDriver(aJsonObject* driver_,  aJsonObject* (* handler_ ) (aJsonObject* request)){
       driver = driver_;
       handler = handler_;
     }
};

uOS uos; // uOS global singleton instance

void setup(){
  Serial.begin(9600); 
  uos.addDriver(NULL,myDriverHandler);
}

aJsonObject* myDriverHandler(aJsonObject* req){
   Serial.println("MyHandler"); 
   return NULL;
}

void loop(){
  Serial.println("\n\n\nTest Start");
  freeMem("Memory at start");
  Serial.println("TEST: Should not show any message");
  uos.receive("not a message");
  Serial.println("TEST: Should show 'Received Message'");
  uos.receive("{\"type\":\"SERVICE_CALL_REQUEST\"}");
  Serial.println("TEST: Should show 'DeviceDriverCall'");
  uos.receive("{\"type\":\"SERVICE_CALL_REQUEST\",\"driver\":\"br.unb.unbiquitous.ubiquitos.driver.DeviceDriver\"}");
  Serial.println("TEST: Should show 'OtherDeviceCall' and 'MyHandler'");
  uos.receive("{\"type\":\"SERVICE_CALL_REQUEST\",\"driver\":\"DummyDriver\"}");
  Serial.println("TEST: Should show 'listDrivers' and the data from listing");
  char* ret = uos.receive("{\"type\":\"SERVICE_CALL_REQUEST\",\"driver\":\"br.unb.unbiquitous.ubiquitos.driver.DeviceDriver\",\"service\":\"listDrivers\"}");
  Serial.println(ret);
  free(ret);
}

//Code to print out the free memory

struct __freelist {
  size_t sz;
  struct __freelist *nx;
};

extern char * const __brkval;
extern struct __freelist *__flp;

uint16_t freeMem(uint16_t *biggest)
{
  char *brkval;
  char *cp;
  unsigned freeSpace;
  struct __freelist *fp1, *fp2;

  brkval = __brkval;
  if (brkval == 0) {
    brkval = __malloc_heap_start;
  }
  cp = __malloc_heap_end;
  if (cp == 0) {
    cp = ((char *)AVR_STACK_POINTER_REG) - __malloc_margin;
  }
  if (cp <= brkval) return 0;

  freeSpace = cp - brkval;

  for (*biggest = 0, fp1 = __flp, fp2 = 0;
     fp1;
     fp2 = fp1, fp1 = fp1->nx) {
      if (fp1->sz > *biggest) *biggest = fp1->sz;
    freeSpace += fp1->sz;
  }

  return freeSpace;
}

uint16_t biggest;

void freeMem(char* message) {
  Serial.print(message);
  Serial.print(":\t");
  Serial.println(freeMem(&biggest));
}
