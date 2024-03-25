#include <omnetpp.h>
#include <string.h>
#include <vector>
#include <map>
#include "inet/linklayer/ethernet/basic/EthernetEncapsulation.h"
#include "inet/linklayer/ethernet/basic/EthernetMac.h"
#include "inet/common/TagBase.h"
#include "inet/physicallayer/wired/ethernet/EthernetPhyHeader_m.h"
#include "inet/linklayer/ieee8021q/Ieee8021qTagHeader_m.h"
#include "inet/transportlayer/udp/UdpHeader_m.h"
#include <inet/transportlayer/contract/udp/UdpSocket.h>
#include <inet/networklayer/common/L3AddressResolver.h>
#include "inet/networklayer/ipv4/Ipv4Header_m.h"
#include "inet/linklayer/common/InterfaceTag_m.h"
#include "inet/networklayer/common/DscpTag_m.h"
#include "inet/networklayer/common/EcnTag_m.h"
#include "inet/networklayer/arp/ipv4/GlobalArp.h"
#include "inet/networklayer/common/MyTag.h"
#include "inet/linklayer/ppp/PppFrame_m.h"
#include "inet/networklayer/common/TosTag_m.h"
#include "inet/networklayer/common/L3AddressTag_m.h"
#include "inet/networklayer/common/HopLimitTag_m.h"
using namespace inet;
using namespace omnetpp;
using namespace std;
class MyNWTT : public cSimpleModule{

        virtual void initialize() override;
        virtual void handleMessage(cMessage *msg) override;
        map<string, string> ipMap;
        map<string, vector<string>> groupMap;
};
Define_Module(MyNWTT);
void MyNWTT::initialize()
{

}


void MyNWTT::handleMessage(cMessage *msg)
{
    EV << msg->getArrivalGate()->getName() << endl;
    if (strcmp(msg->getArrivalGate()->getName(),"upperLayerIn") == 0){

        Packet *pkt = check_and_cast<Packet *>(msg);
        auto iph0 = pkt->peekAtFront<Ipv4Header>();
        string gatewayIpAddress = iph0->getSrcAddress().str();
        pkt->eraseAtFront(B(28));
        pkt->trim();
        pkt->removeTagIfPresent<PacketProtocolTag>();
        pkt->removeTagIfPresent<InterfaceInd>();
        pkt->removeTagIfPresent<DispatchProtocolReq>();
        auto eph = pkt->popAtFront<EthernetPhyHeader>();
        auto emh = pkt->popAtFront<EthernetMacHeader>();
        // TSN
        auto iteh = pkt->popAtFront<Ieee8021qTagEpdHeader>();
        auto iph = pkt->popAtFront<Ipv4Header>();
        string senderIpAddress = iph->getSrcAddress().str();
        ipMap[senderIpAddress] = gatewayIpAddress;
        EV << senderIpAddress << " " << gatewayIpAddress << endl;
        // get destAddress
        auto a = iph->getTag<MyTag>();
        const MacAddress& new_mac = a->destAddress;
        const auto& new_emh = makeShared<EthernetMacHeader>();
        new_emh->setChunkLength(emh->getChunkLength());
        new_emh->setSrc(emh->getSrc());
        new_emh->setDest(new_mac);
        new_emh->setTypeOrLength(emh->getTypeOrLength());
        pkt->insertAtFront(iph);
        pkt->insertAtFront(iteh);
        pkt->insertAtFront(new_emh);
//        pkt->insertAtFront(eph);
//        pkt->addTagIfAbsent<PacketProtocolTag>()->setProtocol(&Protocol::ethernetPhy);
        if (iteh->getPcp() == 0) pkt->setName("besteffort");
        if (iteh->getPcp() == 4) pkt->setName("video");
//        Signal *signal = new Signal(msg->getFullName(), msg->getKind(), pkt->getBitLength());
//        signal->encapsulate(pkt);
//        cGate *physOutGate = gate("phys$o");
//        cChannel *datarateChannel = physOutGate->getTransmissionChannel();
//        while (datarateChannel->isBusy());
        Packet *newPkt = new Packet(*pkt);

        send(newPkt, "lowerLayerOut");
    }
    else if (strcmp(msg->getArrivalGate()->getName(),"lowerLayerIn") == 0) {
        EV << "tets" << endl;
//        Signal *signal = check_and_cast<Signal *>(msg);
        Packet *pkt = check_and_cast<Packet *>(msg);
//        auto eph = pkt->popAtFront<EthernetPhyHeader>();
        auto emh = pkt->popAtFront<EthernetMacHeader>();
        // TSN
        auto iteh = pkt->popAtFront<Ieee8021qTagEpdHeader>();
        auto iph = pkt->popAtFront<Ipv4Header>();
        auto uph = pkt->popAtFront<UdpHeader>();
        pkt->insertAtFront(uph);
        pkt->insertAtFront(iph);
        pkt->insertAtFront(iteh);
        pkt->insertAtFront(emh);
        const auto& eph = makeShared<EthernetPhyHeader>();
        eph->setChunkLength(B(8));
        pkt->insertAtFront(eph);
        const auto& new_uph = makeShared<UdpHeader>();
        new_uph->setDestPort(12340);
        new_uph->setDestinationPort(12340);
        new_uph->setChunkLength(uph->getChunkLength());
        new_uph->setSourcePort(uph->getSourcePort());
        new_uph->setSrcPort(uph->getSrcPort());
        new_uph->setCrc(uph->getCrc());
        new_uph->setCrcMode(uph->getCrcMode());
        new_uph->setTotalLengthField(pkt->getDataLength()+new_uph->getChunkLength());
        pkt->insertAtFront(new_uph);
        Ipv4Address& add = const_cast<Ipv4Address&>(iph->getDestAddress());
        Ipv4Address* new_add = new Ipv4Address(add);

        string destAddress = iph->getDestAddress().str();
        EV << "ip address:" << destAddress << endl;
        if (ipMap.find(destAddress) == ipMap.end()) return ;
        char* destIpAddress = const_cast<char *>(ipMap[destAddress].c_str());
        new_add->set(destIpAddress);
        const auto& new_iph = makeShared<Ipv4Header>();
        new_iph->setDestAddress(*new_add);
        new_iph->setSrcAddress(iph->getSrcAddress());
        new_iph->setChunkLength(iph->getChunkLength());
        new_iph->setCrc(iph->getCrc());
        new_iph->setCrcMode(iph->getCrcMode());
        new_iph->setProtocol(iph->getProtocol());
        new_iph->setProtocolId(iph->getProtocolId());
        new_iph->setOptions(iph->getOptions());
        new_iph->setTimeToLive(iph->getTimeToLive());
        new_iph->setTotalLengthField(pkt->getDataLength()+new_iph->getChunkLength());
        new_iph->setIdentification(iph->getIdentification());
        if (iteh->getPcp() == 0) pkt->setName("besteffort");
        if (iteh->getPcp() == 4) pkt->setName("video");
        pkt->insertAtFront(new_iph);
        pkt->trim();
        pkt->addTagIfAbsent<PacketProtocolTag>()->setProtocol(&Protocol::ipv4);
        EV << "test" << endl;
        send(pkt, "upperLayerOut");
        return;
    }
    else {
        EV << "tets" << endl;
        Signal *signal = check_and_cast<Signal *>(msg);
        Packet *pkt = check_and_cast<Packet *>(signal->decapsulate());
        auto eph = pkt->popAtFront<EthernetPhyHeader>();
        auto emh = pkt->popAtFront<EthernetMacHeader>();
        // TSN
        auto iteh = pkt->popAtFront<Ieee8021qTagEpdHeader>();
        auto iph = pkt->popAtFront<Ipv4Header>();
        auto uph = pkt->popAtFront<UdpHeader>();
        pkt->insertAtFront(uph);
        pkt->insertAtFront(iph);
        pkt->insertAtFront(iteh);
        pkt->insertAtFront(emh);
        pkt->insertAtFront(eph);
        const auto& new_uph = makeShared<UdpHeader>();
        new_uph->setDestPort(12340);
        new_uph->setDestinationPort(12340);
        new_uph->setChunkLength(uph->getChunkLength());
        new_uph->setSourcePort(uph->getSourcePort());
        new_uph->setSrcPort(uph->getSrcPort());
        new_uph->setCrc(uph->getCrc());
        new_uph->setCrcMode(uph->getCrcMode());
        new_uph->setTotalLengthField(pkt->getDataLength()+new_uph->getChunkLength());
        pkt->insertAtFront(new_uph);
        Ipv4Address& add = const_cast<Ipv4Address&>(iph->getDestAddress());
        Ipv4Address* new_add = new Ipv4Address(add);

        string destAddress = iph->getDestAddress().str();
        EV << "ip address:" << destAddress << endl;
        vector<string> ans = opp_split(destAddress, ".");
        int first = stoi(ans[0]);
        if (ipMap.find(iph->getDestAddress().str()) == ipMap.end()) return ;
        char* destIpAddress = const_cast<char *>(ipMap[iph->getDestAddress().str()].c_str());
        new_add->set(destIpAddress);
        const auto& new_iph = makeShared<Ipv4Header>();
        new_iph->setDestAddress(*new_add);
        new_iph->setSrcAddress(iph->getSrcAddress());
        new_iph->setChunkLength(iph->getChunkLength());
        new_iph->setCrc(iph->getCrc());
        new_iph->setCrcMode(iph->getCrcMode());
        new_iph->setProtocol(iph->getProtocol());
        new_iph->setProtocolId(iph->getProtocolId());
        new_iph->setOptions(iph->getOptions());
        new_iph->setTimeToLive(iph->getTimeToLive());
        new_iph->setTotalLengthField(pkt->getDataLength()+new_iph->getChunkLength());
        new_iph->setIdentification(iph->getIdentification());
        pkt->insertAtFront(new_iph);
        pkt->trim();
        pkt->addTagIfAbsent<PacketProtocolTag>()->setProtocol(&Protocol::ipv4);
        send(pkt, "out");

    }


}
