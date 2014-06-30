FIRMWARE_FILE := "BB-DHT22-Pins-00A0.dtbo"
FIRMWARE_DEST := "/lib/firmware/$(FIRMWARE_FILE)"

all: BB-DHT22-Pins-00A0.dtbo

$(FIRMWARE_FILE): BB-DHT22-Pins-00A0.dts
	dtc -O dtb -o $@ -b 0 -@ $<

$(FIRMWARE_DEST): $(FIRMWARE_FILE)
	install "$(FIRMWARE_FILE)" "$(FIRMWARE_DEST)"

install: $(FIRMWARE_DEST)

.PHONY: install
