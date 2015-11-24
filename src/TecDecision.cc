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

Define_Module(TecDecision);

class ChoosenTecMessage: public cMessage {
    tecChoice choice;
public:
    ChoosenTecMessage(cMessage *origin, tecChoice choice): cMessage(*origin){
        this->choice = choice;
    }
    tecChoice getChoice() {
        return choice;
    }
};


void TecDecision::initialize() {
    p = par("p").doubleValue();
}

void TecDecision::handleMessage(cMessage *msg){
    ChoosenTecMessage *pkg = check_and_cast<ChoosenTecMessage*>(msg);
    tecChoice pick;
    if (pkg == NULL)
        pick = chooseTec(msg);
    else
        pick = pkg->getChoice();

    if (msg->arrivedOn("tcpIn")) {
        if (pick == LTE)
            send(new ChoosenTecMessage(msg, LTE), "lteTcpOut");
        if (pick == WIFI)
            send(new ChoosenTecMessage(msg, WIFI), "wifiTcpOut");
    }
    else if (msg->arrivedOn("udpIn")) {
        pick = chooseTec(msg);
        if (pick == LTE)
            send(new ChoosenTecMessage(msg, LTE), "lteTcpOut");
        if (pick == WIFI)
            send(new ChoosenTecMessage(msg, WIFI), "wifiTcpOut");
    }

    else if (msg->arrivedOn("wifiTcpIn") || msg->arrivedOn("lteTcpIn"))
        send(msg, "tcpOut");
    else if (msg->arrivedOn("wifiUdpIn") || msg->arrivedOn("lteUdpIn"))
        send(msg, "udpOut");
}

tecChoice TecDecision::chooseTec(cMessage *msg) {
    double v = uniform(0.0, 1.0);
    if (v < p)
        return LTE;
    else
        return WIFI;
}
