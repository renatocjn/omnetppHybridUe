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

package omnethybridue.simulations;

import inet.nodes.inet.NetworkLayer;
import lte.stack.phy.LteNicUe;
import inet.networklayer.common.InterfaceTable;
import inet.networklayer.ipv4.RoutingTable;

//
// TODO auto-generated type
//
module LteModule
{
    parameters:
        string nodeType = "UE";  // DO NOT CHANGE
        int masterId;
        int macNodeId = default(0); // TODO: this is not a real parameter
        int macCellId = default(0); // TODO: this is not a real parameter

        @display("i=device/antennatower");
    gates:
        input radioIn @directIn;     // connection to master
        input tcpIn;
        input udpIn;
        output tcpOut;
        output udpOut;

    submodules:
        interfaceTable: InterfaceTable {
            @display("p=50,75;is=s");
        }
        routingTable: RoutingTable {
            @display("p=50,125;is=s");
        }
        networkLayer: NetworkLayer {
            @display("p=161,94");
        }
        // NOTE: instance must be named "nic"
        nic: LteNicUe {
            nodeType = nodeType;
            @display("p=161,213");
        }
    connections allowunconnected:

        tcpIn --> networkLayer.transportIn++;
        tcpOut <-- networkLayer.transportOut++;

        udpIn --> networkLayer.transportIn++;
        udpOut <-- networkLayer.transportOut++;

        nic.radioIn <-- radioIn;

        networkLayer.ifOut++ --> nic.upperLayerIn;
        networkLayer.ifIn++ <-- nic.upperLayerOut;
}
