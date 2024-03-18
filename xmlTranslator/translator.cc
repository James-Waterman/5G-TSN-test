#include<omnetpp.h>
#include<string.h>
#include<vector>
#include<map>
using namespace std;
using namespace omnetpp;

typedef pair<string, string> pa;
class XmlReader: public cSimpleModule {
    virtual void initialize() override;
    pa getIpAndMacByUemac(string ueMac);
private:
    map<string, pa> mapClientByUemac;
};
Define_Module(XmlReader)
// 通过ue的mac获取对应Client的ip与mac
// pair<string, string> getIpAndMac(string ueMac);
// 打开文件，初始化map
map<string, pa> xmlInitialize(cXMLElement *father);
void SplitString(const std::string& s, std::vector<std::string>& v, const std::string& c);
void XmlReader::initialize() {
    cXMLElement *father = par("networkconfig").xmlValue();
    this->mapClientByUemac = xmlInitialize(father);
    for (auto i : this->mapClientByUemac) {
        EV << i.first << " " << i.second.first << " " << i.second.second << endl;
    }
//    pa temp = this->getIpAndMacByUemac("0A-AA-01-02-00-01");
//    EV << this->mapClientByUemac.size() << endl;
//    EV << temp.first << " " << temp.second << endl;
}
map<string, pa> xmlInitialize(cXMLElement *father) {
    string str = father->getTagName();
    // list all interface
    cXMLElementList interfaceList = father->getChildren();

    // string type contains client's device name, like TCU0
    // pair type contains clinet's ip(first) and mac(second);
    map<string, pa> mapClientByHost;
    // this array have all ue's information
    // first: device name, like TCU0;
    // second: mac address;
    vector<pa> listUeByName;
    // save to mapClientByHost and mapUeByName
    for (auto iter = interfaceList.begin(); iter != interfaceList.end(); iter++) {
        string ip, mac, deviceStr;
        string hosts = (*iter)->getAttribute("hosts");
        vector<string> deviceName;
        SplitString(hosts, deviceName, "Client");
        if (deviceName.size() == 2) { // if: this component is client
            deviceStr = deviceName[0] + deviceName[1];
            ip = (*iter)->getAttribute("address");
            mac = (*iter)->getAttribute("macaddress");
            mapClientByHost[deviceStr] = make_pair(ip, mac);
        } else { // else: this component is ue or other component
            deviceName.clear();
            SplitString(hosts, deviceName, "Ue");
            if (deviceName.size() == 2) { // is ue
                deviceStr = deviceName[0] + deviceName[1];
                mac = (*iter)->getAttribute("macaddress");
                listUeByName.push_back(make_pair(deviceStr, mac));
            }
        }
    }
    map<string, pa> ans;
    for (auto i : listUeByName) {
        pa temp = mapClientByHost[i.first];
        ans[i.second] = make_pair(temp.first, temp.second);
    }
    return ans;
}
pa XmlReader::getIpAndMacByUemac(string ueMac) {
    return this->mapClientByUemac[ueMac];
}
void SplitString(const std::string& s, std::vector<std::string>& v, const std::string& c)
{
    std::string::size_type pos1, pos2;
    pos2 = s.find(c);
    pos1 = 0;
    while(std::string::npos != pos2) {
        v.push_back(s.substr(pos1, pos2-pos1));
        pos1 = pos2 + c.size();
        pos2 = s.find(c, pos1);
    }
    if(pos1 != s.length())
        v.push_back(s.substr(pos1));
}
