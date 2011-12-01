#include <aJSON.h>

/**
  TODO:
    - Rede:
      - Receber uma mensagem
      - Retornar uma resposta
      - Enviar uma chamada
      - Receber uma resposta
    - Drivers:
      NOK - Listar // Nao consegui fazer a parte de instanciar objetos
      - Expressar a interface
    - Middleware:
      - Traduzir as mensagens
      - Chamar serviços
    
    - Cadastrar Drivers
    - Listar
*/

class uPMessage{
  private:
    aJsonObject *jsonMessage;
  public:
    uPMessage(){
      jsonMessage=aJson.createObject();
    }
    uPMessage(char *strJson){
      jsonMessage = aJson.parse(strJson);
    }
    void setType(char* type){
       aJson.addStringToObject(jsonMessage,"type", type);
    }
    void addParameter(char* param, char* value){
       aJson.addStringToObject(jsonMessage,param,value);
    }
    void addParameter(char* param, aJsonObject* value){
       aJson.addItemToObject(jsonMessage,param,value);
    }
    String getParameter(char* param){
       aJsonObject* value = aJson.getObjectItem(jsonMessage, param);
       return value->valuestring;
    }
    char* message(){return aJson.print(jsonMessage);}
};

class uOSDriver{
  private:
    aJsonObject *jsonDriver;
  public:
    uOSDriver(char* name){
      jsonDriver=aJson.createObject();
      aJson.addStringToObject(jsonDriver, "name",name);
    }
    char* getDriver(){
       return aJson.print(jsonDriver);
    }
    void addService(char* name){
       aJsonObject* services = aJson.getObjectItem(jsonDriver, "services");
       if (services == NULL){
          services = aJson.createArray();
          aJson.addItemToObject(jsonDriver,"services",services);
       }
       aJsonObject* service = aJson.createItem(name);
       aJson.addStringToObject(service,"name", name);
       aJson.addItemToArray(services,service);
    }
    aJsonObject* json(){return jsonDriver;}
};

class DeviceDriver : uOSDriver {
   public:
     DeviceDriver():uOSDriver("br.unb.unbiquitous.ubiquitos.driver.DeviceDriver"){
       addService("listDrivers");
       addService("handshake");
     };
     char* getDriver(){return uOSDriver::getDriver();};// TODO: check this
     void callService(String name, uPMessage request, uPMessage response){
       if (name.equals("listDrivers")) {
           Serial.println("Listing drivers");
           aJsonObject* list = aJson.createArray();
           aJson.addItemToObject(list, "1",uOSDriver::json() );
           char* str = aJson.print(list);
           Serial.print("list:");Serial.println(str);
           freeMem("antes");        
           response.addParameter("driverList",list);
           //TODO: List them
       }else if (name.equals("handshake")) {
           Serial.println("Return device data");
       }
     };

};

class uOS{
   private:
     DeviceDriver deviceDriver;
     char* (* sendHook)(char *msg);
   public:
     uOS(){
        //Destroy
     }
     ~uOS(){
        //Build
     }
     void setSendHook(char* (* hook)(char *msg)) {
       sendHook = hook;
     }
     char* receiveMessage(char *msg){
       Serial.println("Received message");
       uPMessage request(msg);
       uPMessage response;
       response.setType("SERVICE_CALL_RESPONSE");
       if (request.getParameter("type").equals("SERVICE_CALL_REQUEST")){
         if (request.getParameter("driver").equals("br.unb.unbiquitous.ubiquitos.driver.DeviceDriver")){
           deviceDriver.callService(request.getParameter("service"), request, response);
           return response.message();
         }
       }
     }
     char* sendMessage(char *msg){
       return sendHook(msg);
     }
};

uOS uos; // uOS global singleton instance

void setup(){
  Serial.begin(9600); 
}

char* myHook(char *msg){
  Serial.print("Sending message:");
  Serial.println(msg);
}


void loop(){
  Serial.println("\n\n\nTest Start");
  freeMem("Inicio");
  Serial.println("SendHookTest: Should print message mymsg");
  uos.setSendHook(myHook);
  uos.sendMessage("mymsg");
  Serial.println("ReceiveMessageTest: should print 'Listing Drivers' and the response with the DeviceDriver");
  char* response = uos.receiveMessage("{\"type\":\"SERVICE_CALL_REQUEST\",\"serviceType\":\"DISCRETE\",\"driver\":\"br.unb.unbiquitous.ubiquitos.driver.DeviceDriver\",\"service\":\"listDrivers\",\"parameters\":{\"driver\":\"DummyDriver\"}}");
  freeMem("depois");
  Serial.print("Response:");Serial.println(response);
  //Serial.println("Printing the uPDriver of the DeviceDriver");
//  Serial.println(driver.getDriver());
  //Serial.println("Oh no!");
  Serial.println("Test END\n\n\n");
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
