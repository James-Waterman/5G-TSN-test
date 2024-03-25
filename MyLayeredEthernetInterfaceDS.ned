//
// Copyright (C) 2020 OpenSim Ltd.
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//
import inet.linklayer.contract.IEthernetInterface;
import inet.linklayer.ethernet.contract.IEthernetMacLayer;
import inet.networklayer.common.NetworkInterface;
import inet.physicallayer.wired.ethernet.IEthernetPhyLayer;
import inet.protocolelement.measurement.IMeasurementLayer;
import inet.protocolelement.processing.IProcessingDelayLayer;
import inet.protocolelement.trafficconditioner.ITrafficConditionerLayer;
import *;

//
// This module implements an Ethernet network interface.
//
module MyLayeredEthernetInterfaceDS extends NetworkInterface like IEthernetInterface
{
    parameters:
        string protocol = default("ethernetmac");
        bool broadcast = default(true);
        bool multicast = default(true);
        string address @mutable = default("auto");
        double bitrate @unit(bps);
        int mtu @unit(B) = default(1500B);
        string interfaceTableModule;
        *.bitrate = default(this.bitrate);
    gates:
        input upperLayerIn;
        output upperLayerOut;
        input cutthroughIn @loose;
        output cutthroughOut @loose;
        inout phys @labels(EthernetSignal);
    submodules:
        processingDelayLayer: <default("")> like IProcessingDelayLayer {
            parameters:
                @display("p=400,200");
        }
        trafficConditionerLayer: <default("")> like ITrafficConditionerLayer {
            parameters:
                @display("p=400,300");
        }
        measurementLayer: <default("")> like IMeasurementLayer {
            parameters:
                @display("p=400,400");
        }
        macLayer: <default("EthernetMacLayer")> like IEthernetMacLayer {
            parameters:
                @display("p=400,500");
        }
        phyLayer: <default("EthernetPhyLayer")> like IEthernetPhyLayer {
            parameters:
                transmitter.clockModule = default("");
                @display("p=400,600");
        }
        DSTT: TSN5GTranslator {
            parameters:
                @display("p=318,108");
        }
    connections allowunconnected:
        upperLayerIn --> DSTT.upperLayerIn;
        DSTT.lowerLayerOut --> macLayer.upperLayerIn;
        macLayer.lowerLayerOut --> phyLayer.upperLayerIn;
        phyLayer.lowerLayerOut --> { @display("m=s"); } --> phys$o;

        phys$i --> { @display("m=s"); } --> phyLayer.lowerLayerIn;
        phyLayer.upperLayerOut --> macLayer.lowerLayerIn;
        macLayer.upperLayerOut --> DSTT.lowerLayerIn;
        DSTT.upperLayerOut --> upperLayerOut;
}

