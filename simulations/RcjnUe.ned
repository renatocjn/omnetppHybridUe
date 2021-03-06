package omnethybridue.simulations;

import inet.applications.ITCPApp;
import inet.applications.IUDPApp;
import inet.base.NotificationBoard;
import inet.battery.IBattery;
import inet.linklayer.IExternalNic;
import inet.linklayer.IWiredNic;
import inet.linklayer.IWirelessNic;
import inet.linklayer.loopback.LoopbackInterface;
import inet.mobility.contract.IMobility;
import inet.networklayer.IManetRouting;
import inet.networklayer.common.InterfaceTable;
import inet.networklayer.ipv4.RoutingTable;
import inet.nodes.inet.NetworkLayer;
import inet.status.NodeStatus;
import inet.transport.tcp.TCP;
import inet.transport.udp.UDP;
import inet.util.PcapRecorder;
import lte.stack.phy.LteNicUe;


module RcjnUe
{
    parameters:
        @node();
        @display("i=device/pocketpc;bgb=695,583;bgl=24");

        string batteryType = default("");
        bool hasStatus = default(false);

        //# Mobility
        string mobilityType = default("StationaryMobility");

        //# Apps
        int numTcpApps = default(0);  // no of TCP apps. Specify the app types in INI file with tcpApp[0..1].typename="TCPEchoApp" syntax
        int numUdpApps = default(0);  // no of UDP apps. Specify the app types in INI file with udpApp[0..1].typename="UDPVideoStreamCli" syntax

        //# Node specs
        string nodeType = "UE";  // DO NOT CHANGE
        int masterId;
        int macNodeId = default(0); // TODO: this is not a real parameter
        int macCellId = default(0); // TODO: this is not a real parameter

        string routingProtocol @enum("AODVUU","DYMOUM","DYMO","DSRUU","OLSR","OLSR_ETX","DSDV_2","Batman") = default("OLSR");  // used mobile routing protocol. see: inet.networklayer.manetrouting
        int numRadios = default(1);
        string routingFile = default("");
        bool IPForward = default(true);
        bool forwardMulticast = default(false);
        int numPcapRecorders = default(0);
        int numExtInterfaces = default(0);

    gates:
        input radioIn[numRadios+1] @directIn;     // connection to master

        inout pppg[] @labels(PPPFrame-conn);
        inout ethg[] @labels(EtherFrame-conn);

    submodules:
        status: NodeStatus if hasStatus {
            @display("p=50,361");
        }

        notificationBoard: NotificationBoard {
            parameters:
                @display("p=50,218;is=s");
        }

        battery: <batteryType> like IBattery if batteryType != "" {
            parameters:
                @display("p=50,310;i=block/plug;is=s");
        }

        // optional mobility module. Required only if wireless cards are present
        mobility: <mobilityType> like IMobility if mobilityType != "" {
            parameters:
                @display("p=50,260");
        }

        routingTable: RoutingTable {
            parameters:
                @display("p=50,67;is=s");
                IPForward = IPForward;
                forwardMulticast = forwardMulticast;
                routingFile = routingFile;
        }

        // network layer
        networkLayerWIFI: NetworkLayer {
            parameters:
                @display("p=447,353;q=queue");
        }

        networkLayerLTE: NetworkLayer {
            @display("p=188,353");
        }

        // linklayer
        interfaceTable: InterfaceTable {
            parameters:
                @display("p=50,119;is=s");
        }

        pcapRecorder[numPcapRecorders]: PcapRecorder {
            @display("p=50,168,r,10");
        }

        lo0: LoopbackInterface {
            @display("p=467,437");
        }

        wlan[numRadios]: <default("Ieee80211Nic")> like IWirelessNic {
            parameters:
                @display("p=337,466,row,60;q=queue");
        }

        eth[sizeof(ethg)]: <default("EthernetInterface")> like IWiredNic {
            parameters:
                @display("p=533,466,row,60;q=txQueue");
        }

        ppp[sizeof(pppg)]: <default("PPPInterface")> like IWiredNic {
            parameters:
                @display("p=428,505,row,60;q=txQueue");
        }

        ext[numExtInterfaces]: <default("ExtInterface")> like IExternalNic {
            parameters:
                @display("p=607,392,row,10;q=txQueue;i=block/ifcard");
        }

        manetrouting: <routingProtocol> like IManetRouting if routingProtocol != "" {
            @display("p=592,318");
        }

        tcpApp[numTcpApps]: <> like ITCPApp {
            @display("p=188,36,row");
        }

        tcp: TCP if numTcpApps>0 {
            @display("p=188,119");
        }

        udpApp[numUdpApps]: <> like IUDPApp {
            @display("p=447,36,row");
        }

        udp: UDP if numUdpApps>0 {
            @display("p=447,119");
        }

        tecDecision: TecDecision {
            @display("p=311,235");
        }

        // NOTE: instance must be named "nic"
        nic: LteNicUe {
            nodeType = nodeType;
            @display("p=188,466");
        }

    connections allowunconnected:

        for i=0..numUdpApps-1 {
            udpApp[i].udpOut --> udp.appIn++;
            udpApp[i].udpIn <-- udp.appOut++;
        }
        for i=0..numTcpApps-1 {
            tcpApp[i].tcpOut --> tcp.appIn++;
            tcpApp[i].tcpIn <-- tcp.appOut++;
        }
        tcp.ipOut --> tecDecision.tcpIn if numTcpApps > 0;
        tecDecision.tcpOut --> tcp.ipIn if numTcpApps > 0;

        tecDecision.udpOut --> udp.ipIn if numUdpApps > 0;
        udp.ipOut --> tecDecision.udpIn if numUdpApps > 0;

        networkLayerWIFI.ifOut++ --> lo0.upperLayerIn;
        lo0.upperLayerOut --> networkLayerWIFI.ifIn++;

        for i=0..numRadios-1 {
            radioIn[i+1] --> { @display("m=s"); } --> wlan[i].radioIn;
            wlan[i].upperLayerOut --> networkLayerWIFI.ifIn++;
            wlan[i].upperLayerIn <-- networkLayerWIFI.ifOut++;
        }

        for i=0..sizeof(ethg)-1 {
            ethg[i] <--> { @display("m=s"); } <--> eth[i].phys;
            eth[i].upperLayerOut --> networkLayerWIFI.ifIn++;
            eth[i].upperLayerIn <-- networkLayerWIFI.ifOut++;
        }

        for i=0..sizeof(pppg)-1 {
            pppg[i] <--> { @display("m=s"); } <--> ppp[i].phys;
            ppp[i].upperLayerOut --> networkLayerWIFI.ifIn++;
            ppp[i].upperLayerIn <-- networkLayerWIFI.ifOut++;
        }

        for i=0..numExtInterfaces-1 {
            ext[i].upperLayerOut --> networkLayerWIFI.ifIn++;
            ext[i].upperLayerIn <-- networkLayerWIFI.ifOut++;
        }

        networkLayerWIFI.transportOut++ --> manetrouting.from_ip if routingProtocol != "";
        networkLayerWIFI.transportIn++ <-- manetrouting.to_ip if routingProtocol != "";

		// LTE nic connections
        nic.radioIn <-- radioIn[0];
        networkLayerLTE.ifOut++ --> nic.upperLayerIn;
        networkLayerLTE.ifIn++ <-- nic.upperLayerOut;

		// TecDecision <--> NetworkLayerLTE
        tecDecision.wifiTcpOut --> networkLayerWIFI.transportIn++;
        tecDecision.wifiUdpOut --> networkLayerWIFI.transportIn++;
        networkLayerWIFI.transportOut++ --> tecDecision.wifiTcpIn;
        networkLayerWIFI.transportOut++ --> tecDecision.wifiUdpIn;

        // TecDecision <--> NetworkLayerWIFI
        tecDecision.lteTcpOut --> networkLayerLTE.transportIn++;
        tecDecision.lteUdpOut --> networkLayerLTE.transportIn++;
        networkLayerLTE.transportOut++ --> tecDecision.lteTcpIn;
        networkLayerLTE.transportOut++ --> tecDecision.lteUdpIn;


}
