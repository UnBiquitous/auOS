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
    String getParameter(char* param){
       aJsonObject* value = aJson.getObjectItem(jsonMessage, "param");
       return value->valuestring;
    }
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
           //TODO: List them
       }else if (name.equals("handshake")) {
           Serial.println("Return device data");
       }
     };

};

class uOS{
   private:
     DeviceDriver deviceDriver;
     void (* sendHook)(char *msg);
   public:
     uOS(){
        //Destroy
     }
     ~uOS(){
        //Build
     }
     void setSendHook(void (* hook)(char *msg)) {
       sendHook = hook;
     }
     void receiveMessage(char *msg){
       Serial.println("Received message");
       uPMessage request(msg);
       uPMessage response;
       response.setType("SERVICE_CALL_RESPONSE");
       if (request.getParameter("type").equals("SERVICE_CALL_REQUEST")){
         if (request.getParameter("driver").equals("br.unb.unbiquitous.ubiquitos.driver.DeviceDriver")){
           deviceDriver.callService(request.getParameter("service"), request, response);
         }
       }
     }
     void sendMessage(char *msg){
       sendHook(msg);
     }
};

uOS uos; // uOS global singleton instance

void setup(){
  Serial.begin(9600); 
}

void myHook(char *msg){
  Serial.print("Sending message:");
  Serial.println(msg);
}


void loop(){
  Serial.println("\n\n\nTest Start");
  Serial.println("SendHookTest: Should print message mymsg");
  uos.setSendHook(myHook);
  uos.sendMessage("mymsg");
  Serial.println("ReceiveMessageTest: should print 'Listing Drivers'");
  uos.receiveMessage("{type:'SERVICE_CALL_REQUEST',serviceType:'DISCRETE',driver:'br.unb.unbiquitous.ubiquitos.driver.DeviceDriver',service:'listDrivers',parameters:{driver:'DummyDriver'}}");
  //Serial.println("Printing the uPDriver of the DeviceDriver");
//  Serial.println(driver.getDriver());
  //Serial.println("Oh no!");
}
