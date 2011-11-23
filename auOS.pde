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
    void setType(char* type){
       aJson.addStringToObject(jsonMessage,"type", type);
    }
    void addParameter(char* param, char* value){
       aJson.addStringToObject(jsonMessage,param,value);
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
     void (* sendHook)(char *msg, int size);
   public:
     uOS(){
        //Destroy
     }
     ~uOS(){
        //Build
     }
     void setSendHook(void (* hook)(char *msg, int size)) {
       sendHook = hook;
     }
     void receiveMessage(char *msg, int size){
       Serial.println("Received message"); 
     }
     void sendMessage(char *msg, int size){
       sendHook(msg,size);
     }
};

uOS uos; // uOS global singleton instance

void setup(){
  Serial.begin(9600); 
}

void myHook(char *msg, int size){
  Serial.print("Sending ");
  Serial.print(size);
  Serial.print(" bytes of message :");
  Serial.println(msg);
}


void loop(){
  Serial.println("\n\n\nTest Start");
  Serial.println("SendHookTest");
  uos.setSendHook(myHook);
  uos.sendMessage("mymsg",5);
  //Serial.println("Printing the uPDriver of the DeviceDriver");
//  Serial.println(driver.getDriver());
  //Serial.println("Oh no!");
}
