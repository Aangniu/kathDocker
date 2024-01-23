#include <iostream>

#include <string>

#include "umbridge.h"

#include <chrono>
#include <thread>
#include <iomanip>
#include <stdlib.h>

class SeisSol_Model : public umbridge::Model {
public:

  SeisSol_Model(int ranks)
   : Model("forward"), ranks(ranks)
  {
    char const* shared_dir_cstr = std::getenv("SHARED_DIR");
    if ( shared_dir_cstr == NULL ) {
      std::cerr << "Environment variable SHARED_DIR not set!" << std::endl;
      exit(-1);
    }
    shared_dir = std::string(shared_dir_cstr);
  }

  std::vector<std::size_t> GetInputSizes(const json& config) const override {
    return {2};
  }

  std::vector<std::size_t> GetOutputSizes(const json& config) const override {
    return {49};
  }

  std::vector<std::vector<double>> Evaluate(std::vector<std::vector<double>> const& inputs, json config) override {
    std::cout << "Reading options" << std::endl;
    int level = config.value("level", 0);
    std::cout << "Reading options" << std::endl;
    bool verbose = config.value("verbosity", false);
    bool vtk_output = config.value("vtk_output", false);

    std::cout << "Entered for level " << level << std::endl;

    std::ofstream inputsfile (shared_dir + "/in.txt");
    typedef std::numeric_limits<double> dl;
    inputsfile << std::fixed << std::setprecision(dl::digits10);
    for (int i = 0; i < inputs[0].size(); i++) {
      inputsfile << inputs[0][i] << std::endl;
    }
    inputsfile.close();

    int status;
    // if(verbose) {
    //     system("cd /ExaHyPE-Tsunami/ApplicationExamples/SWE/SWE_asagi_limited_l0 && cp exahype_debug.log-filter exahype.log-filter");
    //     system("cd /ExaHyPE-Tsunami/ApplicationExamples/SWE/SWE_asagi_limited_l1 && cp exahype_debug.log-filter exahype.log-filter");
    //     system("cd /ExaHyPE-Tsunami/ApplicationExamples/SWE/SWE_asagi_limited_l2 && cp exahype_debug.log-filter exahype.log-filter");
    // } else{
    //     system("cd /ExaHyPE-Tsunami/ApplicationExamples/SWE/SWE_asagi_limited_l0 && cp exahype_release.log-filter exahype.log-filter");
    //     system("cd /ExaHyPE-Tsunami/ApplicationExamples/SWE/SWE_asagi_limited_l1 && cp exahype_release.log-filter exahype.log-filter");
    //     system("cd /ExaHyPE-Tsunami/ApplicationExamples/SWE/SWE_asagi_limited_l2 && cp exahype_release.log-filter exahype.log-filter");
    // }
    // if(vtk_output){
    //     system("cd /ExaHyPE-Tsunami/ApplicationExamples/SWE && sed -i 's/\"time\": 10000.0,/\"time\": 1.0,/g' SWE_asagi_limited_l0.exahype2");
    //     system("cd /ExaHyPE-Tsunami/ApplicationExamples/SWE && sed -i 's/\"time\": 10000.0,/\"time\": 1.0,/g' SWE_asagi_limited_l1.exahype2");
    //     system("cd /ExaHyPE-Tsunami/ApplicationExamples/SWE && sed -i 's/\"time\": 10000.0,/\"time\": 1.0,/g' SWE_asagi_limited_l2.exahype2");
    // } else{
    //     system("cd /ExaHyPE-Tsunami/ApplicationExamples/SWE && sed -i 's/\"time\": 1.0,/\"time\": 10000.0,/g' SWE_asagi_limited_l0.exahype2");
    //     system("cd /ExaHyPE-Tsunami/ApplicationExamples/SWE && sed -i 's/\"time\": 1.0,/\"time\": 10000.0,/g' SWE_asagi_limited_l1.exahype2");
    //     system("cd /ExaHyPE-Tsunami/ApplicationExamples/SWE && sed -i 's/\"time\": 1.0,/\"time\": 10000.0,/g' SWE_asagi_limited_l2.exahype2");
    // }
    if(level == 0) {
      std::string cmd = "cd /home/ParameterFiles && python3 generate_kathMat.py && rm -rf output/** && sbatch test_0p1HzCdam34.sh";
      status = system(cmd.c_str());
      std::string cmd2 = "cd /home/ParameterFiles && python3 postprocessing.py";
      status = system(cmd2.c_str());
    } else {
      std::cerr << "Unknown model requested by client!" << std::endl;
      exit(-1);
    }
    std::cout << "SeisSol exit status " << status << std::endl;

    std::vector<std::vector<double>> outputs(1);
    outputs[0] = std::vector<double>(49);
    {
    // std::ifstream outputsfile(shared_dir + "/out.txt");
    std::ifstream outputsfile("/home/ParameterFiles/out.txt");
    for (int i = 0; i < 49; i++) {
      outputsfile >> outputs[0][i];
    }
    outputsfile.close();
    }

    // Print output zero from exahype
    std::cout << "Outputs read from seissol: " << std::endl;
    for (std::size_t i = 0; i < outputs[0].size(); i++) {
      std::cout << outputs[0][i] << std::endl;
    }

    std::cout << "Left" << std::endl;
    return outputs;
  }

  bool SupportsEvaluate() override {
    return true;
  }
private:
  int ranks;
  std::string shared_dir;
};

int main(){

  char const* port_cstr = std::getenv("PORT");
  if ( port_cstr == NULL ) {
    std::cerr << "Environment variable PORT not set!" << std::endl;
    exit(-1);
  }
  const int port = atoi(port_cstr);

  char const* ranks_cstr =  std::getenv("RANKS");
  if ( ranks_cstr == NULL ) {
    std::cerr << "Environment variable RANKS not set!" << std::endl;
    exit(-1);
  }
  const int ranks = atoi(ranks_cstr);

  SeisSol_Model model(ranks);
  std::vector<umbridge::Model*> models {&model};
  umbridge::serveModels(models, "0.0.0.0", port);

  return 0;
}
