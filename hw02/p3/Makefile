

TECH_DIR=/mnt/coe/workspace/ece/ece720-common/tech/nangate/Nangate_15nm_OCL_OA22.50/si2
LAYER_MAP=$(TECH_DIR)/layer.map
REFLIB_DIR=$(TECH_DIR)/nangate
DESIGN = Rocket


shape: newlib/$(DESIGN)/layout/layout.oa
	python3 listShape.py $(DESIGN)

newlib/$(DESIGN)/layout/layout.oa: $(DESIGN).def lib.defs
	-def2oa -def $(DESIGN).def -lib newlib -libPath ./newlib -layerMap $(LAYER_MAP) -libDefFile lib.defs -refLibs nangate -techLib nangate


lib.defs:
	echo DEFINE nangate $(REFLIB_DIR) > lib.defs


clean:
	-rm -rf newlib
	-rm lib.defs
	-rm def2oa.log
