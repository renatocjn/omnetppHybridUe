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

#ifndef TECDECISION_H_
#define TECDECISION_H_

#include <csimplemodule.h>
#include <omnetpp.h>

class TecDecision: public cSimpleModule {
protected:
    enum tecChoice {LTE, WIFI};

    virtual void initialize();
    virtual void handleMessage(cMessage *msg);

private:
    double p;

    tecChoice chooseTec(cMessage *msg);
    void sendThroughChoosenTec(cMessage *msg, tecChoice pick);
};

#endif /* TECDECISION_H_ */
