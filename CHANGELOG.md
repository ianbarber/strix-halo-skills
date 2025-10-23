# Changelog

All notable changes to the Strix Halo Skills project will be documented in this file.

## [1.0.0] - October 23, 2025

### Initial Release

**Verified Capabilities:**
- 30B parameter models in FP16 (tested up to 62.8 GB memory usage)
- 12 TFLOPS BF16 compute, 7 TFLOPS FP32
- 229 GB/s write bandwidth, 201 GB/s copy bandwidth
- 113 GB GPU-accessible memory with GTT configuration

### Added

**Claude Code Skills:**
- `strix-halo-setup` - Complete automated project setup
- `QUICK_REFERENCE` - Quick command reference
- `STRIX_HALO_COMPLETE_GUIDE` - Comprehensive documentation access

**Scripts:**
- `setup_new_project.sh` - Automated project creation with conda environment
- `configure_gtt.sh` - GTT memory configuration helper
- `scripts/test_gpu_simple.py` - Quick GPU verification
- `scripts/test_memory.py` - Progressive memory allocation testing
- `scripts/test_llm_memory.py` - LLM capacity simulation testing
- `scripts/amd_benchmark_safe.py` - Safe performance benchmarking

**Documentation:**
- `STRIX_HALO_COMPLETE_GUIDE.md` - Complete setup guide with verified October 2025 results
- `GTT_MEMORY_FIX.md` - GTT memory configuration details
- `TROUBLESHOOTING.md` - Common issues and solutions
- `GETTING_STARTED.md` - First-time user guide
- `USAGE_IN_OTHER_PROJECTS.md` - How to use skills in other projects
- `PUBLISHING_GUIDE.md` - How to publish and share the repository

### Key Features

**PyTorch Installation:**
- Documents that official PyTorch wheels don't work with gfx1151
- Provides working installation via AMD nightlies: `pip install --index-url https://rocm.nightlies.amd.com/v2/gfx1151/ --pre torch`
- Alternative community builds from [@scottt](https://github.com/scottt/rocm-TheRock)

**GTT Configuration:**
- Kernel parameters for 108GB GTT: `amdttm.pages_limit=27648000`
- Supports up to 128GB GTT on systems with sufficient RAM
- Automatic configuration via `configure_gtt.sh`

**Environment Setup:**
- Automatic conda environment creation
- Environment variables configured via activation scripts
- Includes all necessary ROCm optimizations (HSA_XNACK, ROCBLAS_USE_HIPBLASLT, etc.)

**Alternative Backends:**
- Documentation for Vulkan backend (often faster for inference)
- Performance comparison between Vulkan and ROCm/HIP

### Tested Configuration

- **Hardware**: AMD Ryzen AI MAX+ 395 (Strix Halo, gfx1151)
- **ROCm**: 6.4.2 (system drivers)
- **PyTorch**: 2.7.0a0 + HIP 6.5.25190 (community build)
- **Linux Kernel**: 6.14.0-33-generic
- **OS**: Ubuntu 24.04 LTS
- **System RAM**: 64 GB
- **GTT**: Configured to 113 GB

### Performance Results

| Benchmark | Result |
|-----------|--------|
| FP32 Compute (1024x1024) | 7.77 TFLOPS |
| BF16 Compute (1024x1024) | 12.32 TFLOPS |
| FP32 Compute (2048x2048) | 6.95 TFLOPS |
| BF16 Compute (2048x2048) | 12.03 TFLOPS |
| Memory Write Bandwidth | 229 GB/s |
| Memory Copy Bandwidth | 201 GB/s |
| 7B Model (FP16) | ✅ 14.0 GB allocated |
| 13B Model (FP16) | ✅ 26.5 GB allocated |
| 30B Model (FP16) | ✅ 60.8 GB allocated |
| 65B Model (FP16) | ❌ Exceeds available RAM |

### Known Limitations

- Official PyTorch wheels don't work (requires community builds)
- Flash Attention not working on gfx1151 as of ROCm 6.5
- Compute efficiency around 21-26% of theoretical peak
- 65B+ models require more than 64GB system RAM

### Credits

- **Created by**: Ian Barber
- **Community PyTorch builds**: [@scottt](https://github.com/scottt/rocm-TheRock)
- **ROCm team** and community contributors
- Research from llm-tracker.info, Jeff Geerling, and ROCm/TheRock community

---

## Future Releases

### Planned for Future Versions

- Examples directory with working inference scripts
- Support for ROCm 7.0+ when stable
- Windows setup instructions (ROCm 6.4.4+ supports Windows)
- Model compatibility matrix
- Performance tuning guide
- Video walkthrough

### How to Report Issues

- GitHub Issues: https://github.com/ianbarber/strix-halo-skills/issues
- Include: ROCm version, PyTorch version, error messages, system specs

### How to Contribute

See `PUBLISHING_GUIDE.md` for information on contributing improvements.

---

*Note: Semantic versioning will be used for future releases. This initial release is 1.0.0 as it represents a complete, tested, and documented solution.*
