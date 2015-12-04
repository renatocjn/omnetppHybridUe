//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

#include <TecDecision.h>
#include "IPProtocolId_m.h"
#include "IPv4ControlInfo.h"
#include "IPv4Datagram.h"
#include "IPv4InterfaceData.h"

Define_Module(TecDecision);

//class ChoosenTecMessage: public cMessage {
//    tecChoice choice;
//public:
//    ChoosenTecMessage(cMessage *origin, tecChoice choice): cMessage(*origin){
//        this->choice = choice;
//    }
//    tecChoice getChoice() {
//        return choice;
//    }
//};

void TecDecision::initialize() {
    p = par("p").doubleValue();
}

void TecDecision::handleMessage(cMessage *msg){
    if (msg->arrivedOn("tcpIn")) {
        tecChoice pick = chooseTec(msg);
        if (pick == LTE){
            send(msg, "lteTcpOut");
        }
        if (pick == WIFI) {
            send(msg, "wifiTcpOut");
        }
    }
    else if (msg->arrivedOn("udpIn")) {
        tecChoice pick = chooseTec(msg);
        if (pick == LTE){
           send(msg, "lteUdpOut");
        }
        if (pick == WIFI) {
            send(msg, "wifiUdpOut");
        }
    }
    else if (msg->arrivedOn("wifiTcpIn") || msg->arrivedOn("lteTcpIn"))
        delete msg;
    else if (msg->arrivedOn("wifiUdpIn") || msg->arrivedOn("lteUdpIn"))
        delete msg;
}

tecChoice TecDecision::chooseTec(cMessage *msg) {
    double v = uniform(0.0, 1.0);
    if (v < p)
        return LTE;
    else
        return WIFI;
}
