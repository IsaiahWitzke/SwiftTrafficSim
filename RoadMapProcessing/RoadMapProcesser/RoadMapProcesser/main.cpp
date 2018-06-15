
//I didnt write (most of) the following. Stackoverflow user that did: https://stackoverflow.com/users/4129592/didil
//Im going through the code now and am realizing that most of it is really bad...
//I do not want to be associated with this poo poo code
//THE ORIGINAL CODE DIDNT EVEN CLOSE THE FILE

#include <fstream>
#include <iostream>
#include <string>
#include <array>
#include <vector>
#include <iterator>

using namespace std;

vector<int> readBMP(const string &file)
{
    static constexpr size_t HEADER_SIZE = 54;
    
    ifstream bmp(file, ios::binary);
    
    array<char, HEADER_SIZE> header;
    bmp.read(header.data(), header.size());
    
    auto dataOffset = *reinterpret_cast<uint32_t *>(&header[10]);
    auto width = *reinterpret_cast<uint32_t *>(&header[18]);
    auto height = *reinterpret_cast<uint32_t *>(&header[22]);
    
    cout << "dataOffset = " << dataOffset << " width = " << width << " height = " << height << endl;
    
    vector<char> img(dataOffset - HEADER_SIZE);
    bmp.read(img.data(), img.size());
    
    auto dataSize = ((width * 3 + 3) & (~3)) * height;
    img.resize(dataSize);
    bmp.read(img.data(), img.size());
    
    char temp = 0;
    
    vector<int> RGBArr;
    
    //IMPORTANT PART THAT I (kinda) WROTE
    //go through the entire file and turn it into int data
    for (auto i = 0; i < dataSize; i += 3)
    {
        temp = img[i];
        img[i] = img[i+2];
        img[i+2] = temp;
        
        cout << i/3 << ": " << "R: " << int(img[i] & 0xff) << " G: " << int(img[i+1] & 0xff) << " B: " << int(img[i+2] & 0xff) << endl;
        
        RGBArr.push_back(int(img[i] & 0xff));
        RGBArr.push_back(int(img[i+1] & 0xff));
        RGBArr.push_back(int(img[i+2] & 0xff));
    }
    
    bmp.close();
    
    return RGBArr;
}

int main()
{
    
    //this path will need to be edited to the abs location of the trafficSim's RoadMap.bmp
    vector<int> roadMapAsNumbers = readBMP("/Users/student2018/Documents/GitHub/SwiftTrafficSim/RoadMapProcessing/RoadMap.bmp");
    
    ofstream outPutFlie;
    //will need to replace "student2018" with actuall usr account name
    outPutFlie.open ("/Users/student2018/Documents/ProcessedRoadMap.txt", ofstream::trunc);
    cout << roadMapAsNumbers.size() << endl;
    
    for (int i = 0; i < roadMapAsNumbers.size(); i++)
    {
        outPutFlie << roadMapAsNumbers[i];
        outPutFlie << " ";
    }
    
    outPutFlie.close();
    
    return 0;
}

