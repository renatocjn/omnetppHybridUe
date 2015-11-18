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

//
// Module for deciding which tecnology to use to send a packet, 
// from a tcp or udp pkg decide if it is better to send through wifi or LTE
//
simple TecDecision
{
    parameters:
        double p = default(0.5); //Porcentagem da carga utilizada no LTE, o resto utiliza wifi ad hoc 
	
	gates:
	    input udpIn;
	    output udpOut;
	    input tcpIn;
	    output tcpOut;
	    
	    input wifiTcpIn;
	    output wifiTcpOut;
	    input wifiUdpIn;
	    output wifiUdpOut;
	    
	    input lteTcpIn;
	    output lteTcpOut;
	    input lteUdpIn;
	    output lteUdpOut;
}
