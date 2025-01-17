import CVulkan

public class Entry {
    public let loader: Loader
    let dispatchTable: EntryDispatchTable

    public init(loader: Loader) {
        self.loader = loader
        self.dispatchTable = EntryDispatchTable(vkGetInstanceProcAddr: self.loader.vkGetInstanceProcAddr)
    }

    public func createInstance(createInfo: InstanceCreateInfo) throws -> Instance {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkInstance!
            try checkResult(
                self.dispatchTable.vkCreateInstance(ptr_createInfo, nil, &out)
            )
            return Instance(handle: out, entry: self)
        }
    }

    public func getInstanceProcAddr(instance: Instance?, name: String) -> PFN_vkVoidFunction? {
        name.withCString { cString_name in
            self.loader.vkGetInstanceProcAddr(instance?.handle, cString_name)
        }
    }

    public func getInstanceVersion() throws -> Version {
        var out = UInt32()
        try checkResult(
            self.dispatchTable.vkEnumerateInstanceVersion(&out)
        )
        return Version(rawValue: out)
    }

    public func getInstanceLayerProperties() throws -> Array<LayerProperties> {
        try enumerate { pProperties, pPropertyCount in
            self.dispatchTable.vkEnumerateInstanceLayerProperties(pPropertyCount, pProperties)
        }.map { LayerProperties(cStruct: $0) }
    }

    public func getInstanceExtensionProperties(layerName: String?) throws -> Array<ExtensionProperties> {
        try layerName.withOptionalCString { cString_layerName in
            try enumerate { pProperties, pPropertyCount in
                self.dispatchTable.vkEnumerateInstanceExtensionProperties(cString_layerName, pPropertyCount, pProperties)
            }.map { ExtensionProperties(cStruct: $0) }
        }
    }
}

public class Instance: _HandleContainer {
    public let handle: VkInstance?
    public let entry: Entry
    let dispatchTable: InstanceDispatchTable

    public init(handle: VkInstance!, entry: Entry) {
        self.handle = handle
        self.entry = entry
        self.dispatchTable = InstanceDispatchTable(vkGetInstanceProcAddr: self.entry.loader.vkGetInstanceProcAddr, instance: handle)
    }

    public func destroy() -> Void {
        self.dispatchTable.vkDestroyInstance(self.handle, nil)
    }

    public func getPhysicalDevices() throws -> Array<PhysicalDevice> {
        try enumerate { pPhysicalDevices, pPhysicalDeviceCount in
            self.dispatchTable.vkEnumeratePhysicalDevices(self.handle, pPhysicalDeviceCount, pPhysicalDevices)
        }.map { PhysicalDevice(handle: $0, instance: self) }
    }

    public func createDisplayPlaneSurfaceKHR(createInfo: DisplaySurfaceCreateInfoKHR) throws -> SurfaceKHR {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkSurfaceKHR!
            try checkResult(
                self.dispatchTable.vkCreateDisplayPlaneSurfaceKHR(self.handle, ptr_createInfo, nil, &out)
            )
            return SurfaceKHR(handle: out, instance: self)
        }
    }

    public func createDebugReportCallbackEXT(createInfo: DebugReportCallbackCreateInfoEXT) throws -> DebugReportCallbackEXT {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkDebugReportCallbackEXT!
            try checkResult(
                self.dispatchTable.vkCreateDebugReportCallbackEXT(self.handle, ptr_createInfo, nil, &out)
            )
            return DebugReportCallbackEXT(handle: out, instance: self)
        }
    }

    public func debugReportMessageEXT(flags: DebugReportFlagsEXT, objectType: DebugReportObjectTypeEXT, object: UInt64, location: Int, messageCode: Int32, layerPrefix: String, message: String) -> Void {
        layerPrefix.withCString { cString_layerPrefix in
            message.withCString { cString_message in
                self.dispatchTable.vkDebugReportMessageEXT(self.handle, flags.rawValue, VkDebugReportObjectTypeEXT(rawValue: objectType.rawValue), object, location, messageCode, cString_layerPrefix, cString_message)
            }
        }
    }

    public func getPhysicalDeviceGroups() throws -> Array<PhysicalDeviceGroupProperties> {
        try enumerate { pPhysicalDeviceGroupProperties, pPhysicalDeviceGroupCount in
            self.dispatchTable.vkEnumeratePhysicalDeviceGroups(self.handle, pPhysicalDeviceGroupCount, pPhysicalDeviceGroupProperties)
        }.map { PhysicalDeviceGroupProperties(cStruct: $0, instance: self) }
    }

    public func createDebugUtilsMessengerEXT(createInfo: DebugUtilsMessengerCreateInfoEXT) throws -> DebugUtilsMessengerEXT {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkDebugUtilsMessengerEXT!
            try checkResult(
                self.dispatchTable.vkCreateDebugUtilsMessengerEXT(self.handle, ptr_createInfo, nil, &out)
            )
            return DebugUtilsMessengerEXT(handle: out, instance: self)
        }
    }

    public func submitDebugUtilsMessageEXT(messageSeverity: DebugUtilsMessageSeverityFlagsEXT, messageTypes: DebugUtilsMessageTypeFlagsEXT, callbackData: DebugUtilsMessengerCallbackDataEXT) -> Void {
        callbackData.withCStruct { ptr_callbackData in
            self.dispatchTable.vkSubmitDebugUtilsMessageEXT(self.handle, VkDebugUtilsMessageSeverityFlagBitsEXT(rawValue: messageSeverity.rawValue), messageTypes.rawValue, ptr_callbackData)
        }
    }

    public func createHeadlessSurfaceEXT(createInfo: HeadlessSurfaceCreateInfoEXT) throws -> SurfaceKHR {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkSurfaceKHR!
            try checkResult(
                self.dispatchTable.vkCreateHeadlessSurfaceEXT(self.handle, ptr_createInfo, nil, &out)
            )
            return SurfaceKHR(handle: out, instance: self)
        }
    }
}

public class PhysicalDevice: _HandleContainer {
    public let handle: VkPhysicalDevice?
    public let instance: Instance

    public init(handle: VkPhysicalDevice!, instance: Instance) {
        self.handle = handle
        self.instance = instance
    }

    public func getProperties() -> PhysicalDeviceProperties {
        var out = VkPhysicalDeviceProperties()
        self.instance.dispatchTable.vkGetPhysicalDeviceProperties(self.handle, &out)
        return PhysicalDeviceProperties(cStruct: out)
    }

    public func getQueueFamilyProperties() -> Array<QueueFamilyProperties> {
        enumerate { pQueueFamilyProperties, pQueueFamilyPropertyCount in
            self.instance.dispatchTable.vkGetPhysicalDeviceQueueFamilyProperties(self.handle, pQueueFamilyPropertyCount, pQueueFamilyProperties)
        }.map { QueueFamilyProperties(cStruct: $0) }
    }

    public func getMemoryProperties() -> PhysicalDeviceMemoryProperties {
        var out = VkPhysicalDeviceMemoryProperties()
        self.instance.dispatchTable.vkGetPhysicalDeviceMemoryProperties(self.handle, &out)
        return PhysicalDeviceMemoryProperties(cStruct: out)
    }

    public func getFeatures() -> PhysicalDeviceFeatures {
        var out = VkPhysicalDeviceFeatures()
        self.instance.dispatchTable.vkGetPhysicalDeviceFeatures(self.handle, &out)
        return PhysicalDeviceFeatures(cStruct: out)
    }

    public func getFormatProperties(format: Format) -> FormatProperties {
        var out = VkFormatProperties()
        self.instance.dispatchTable.vkGetPhysicalDeviceFormatProperties(self.handle, VkFormat(rawValue: format.rawValue), &out)
        return FormatProperties(cStruct: out)
    }

    public func getImageFormatProperties(format: Format, type: ImageType, tiling: ImageTiling, usage: ImageUsageFlags, flags: ImageCreateFlags) throws -> ImageFormatProperties {
        var out = VkImageFormatProperties()
        try checkResult(
            self.instance.dispatchTable.vkGetPhysicalDeviceImageFormatProperties(self.handle, VkFormat(rawValue: format.rawValue), VkImageType(rawValue: type.rawValue), VkImageTiling(rawValue: tiling.rawValue), usage.rawValue, flags.rawValue, &out)
        )
        return ImageFormatProperties(cStruct: out)
    }

    public func createDevice(createInfo: DeviceCreateInfo) throws -> Device {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkDevice!
            try checkResult(
                self.instance.dispatchTable.vkCreateDevice(self.handle, ptr_createInfo, nil, &out)
            )
            return Device(handle: out, physicalDevice: self)
        }
    }

    public func getDeviceLayerProperties() throws -> Array<LayerProperties> {
        try enumerate { pProperties, pPropertyCount in
            self.instance.dispatchTable.vkEnumerateDeviceLayerProperties(self.handle, pPropertyCount, pProperties)
        }.map { LayerProperties(cStruct: $0) }
    }

    public func getDeviceExtensionProperties(layerName: String?) throws -> Array<ExtensionProperties> {
        try layerName.withOptionalCString { cString_layerName in
            try enumerate { pProperties, pPropertyCount in
                self.instance.dispatchTable.vkEnumerateDeviceExtensionProperties(self.handle, cString_layerName, pPropertyCount, pProperties)
            }.map { ExtensionProperties(cStruct: $0) }
        }
    }

    public func getSparseImageFormatProperties(format: Format, type: ImageType, samples: SampleCountFlags, usage: ImageUsageFlags, tiling: ImageTiling) -> Array<SparseImageFormatProperties> {
        enumerate { pProperties, pPropertyCount in
            self.instance.dispatchTable.vkGetPhysicalDeviceSparseImageFormatProperties(self.handle, VkFormat(rawValue: format.rawValue), VkImageType(rawValue: type.rawValue), VkSampleCountFlagBits(rawValue: samples.rawValue), usage.rawValue, VkImageTiling(rawValue: tiling.rawValue), pPropertyCount, pProperties)
        }.map { SparseImageFormatProperties(cStruct: $0) }
    }

    public func getDisplayPropertiesKHR() throws -> Array<DisplayPropertiesKHR> {
        try enumerate { pProperties, pPropertyCount in
            self.instance.dispatchTable.vkGetPhysicalDeviceDisplayPropertiesKHR(self.handle, pPropertyCount, pProperties)
        }.map { DisplayPropertiesKHR(cStruct: $0, physicalDevice: self) }
    }

    public func getDisplayPlanePropertiesKHR() throws -> Array<DisplayPlanePropertiesKHR> {
        try enumerate { pProperties, pPropertyCount in
            self.instance.dispatchTable.vkGetPhysicalDeviceDisplayPlanePropertiesKHR(self.handle, pPropertyCount, pProperties)
        }.map { DisplayPlanePropertiesKHR(cStruct: $0, physicalDevice: self) }
    }

    public func getDisplayPlaneSupportedDisplaysKHR(planeIndex: UInt32) throws -> Array<DisplayKHR> {
        try enumerate { pDisplays, pDisplayCount in
            self.instance.dispatchTable.vkGetDisplayPlaneSupportedDisplaysKHR(self.handle, planeIndex, pDisplayCount, pDisplays)
        }.map { DisplayKHR(handle: $0, physicalDevice: self) }
    }

    public func getSurfaceSupportKHR(queueFamilyIndex: UInt32, surface: SurfaceKHR) throws -> Bool {
        var out = VkBool32()
        try checkResult(
            self.instance.dispatchTable.vkGetPhysicalDeviceSurfaceSupportKHR(self.handle, queueFamilyIndex, surface.handle, &out)
        )
        return out == VK_TRUE
    }

    public func getSurfaceCapabilitiesKHR(surface: SurfaceKHR) throws -> SurfaceCapabilitiesKHR {
        var out = VkSurfaceCapabilitiesKHR()
        try checkResult(
            self.instance.dispatchTable.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(self.handle, surface.handle, &out)
        )
        return SurfaceCapabilitiesKHR(cStruct: out)
    }

    public func getSurfaceFormatsKHR(surface: SurfaceKHR) throws -> Array<SurfaceFormatKHR> {
        try enumerate { pSurfaceFormats, pSurfaceFormatCount in
            self.instance.dispatchTable.vkGetPhysicalDeviceSurfaceFormatsKHR(self.handle, surface.handle, pSurfaceFormatCount, pSurfaceFormats)
        }.map { SurfaceFormatKHR(cStruct: $0) }
    }

    public func getSurfacePresentModesKHR(surface: SurfaceKHR) throws -> Array<PresentModeKHR> {
        try enumerate { pPresentModes, pPresentModeCount in
            self.instance.dispatchTable.vkGetPhysicalDeviceSurfacePresentModesKHR(self.handle, surface.handle, pPresentModeCount, pPresentModes)
        }.map { PresentModeKHR(rawValue: $0.rawValue)! }
    }

    public func getExternalImageFormatPropertiesNV(format: Format, type: ImageType, tiling: ImageTiling, usage: ImageUsageFlags, flags: ImageCreateFlags, externalHandleType: ExternalMemoryHandleTypeFlagsNV) throws -> ExternalImageFormatPropertiesNV {
        var out = VkExternalImageFormatPropertiesNV()
        try checkResult(
            self.instance.dispatchTable.vkGetPhysicalDeviceExternalImageFormatPropertiesNV(self.handle, VkFormat(rawValue: format.rawValue), VkImageType(rawValue: type.rawValue), VkImageTiling(rawValue: tiling.rawValue), usage.rawValue, flags.rawValue, externalHandleType.rawValue, &out)
        )
        return ExternalImageFormatPropertiesNV(cStruct: out)
    }

    public func getFeatures2() -> PhysicalDeviceFeatures2 {
        var out = VkPhysicalDeviceFeatures2()
        self.instance.dispatchTable.vkGetPhysicalDeviceFeatures2(self.handle, &out)
        return PhysicalDeviceFeatures2(cStruct: out)
    }

    public func getProperties2() -> PhysicalDeviceProperties2 {
        var out = VkPhysicalDeviceProperties2()
        self.instance.dispatchTable.vkGetPhysicalDeviceProperties2(self.handle, &out)
        return PhysicalDeviceProperties2(cStruct: out)
    }

    public func getFormatProperties2(format: Format) -> FormatProperties2 {
        var out = VkFormatProperties2()
        self.instance.dispatchTable.vkGetPhysicalDeviceFormatProperties2(self.handle, VkFormat(rawValue: format.rawValue), &out)
        return FormatProperties2(cStruct: out)
    }

    public func getImageFormatProperties2(imageFormatInfo: PhysicalDeviceImageFormatInfo2) throws -> ImageFormatProperties2 {
        try imageFormatInfo.withCStruct { ptr_imageFormatInfo in
            var out = VkImageFormatProperties2()
            try checkResult(
                self.instance.dispatchTable.vkGetPhysicalDeviceImageFormatProperties2(self.handle, ptr_imageFormatInfo, &out)
            )
            return ImageFormatProperties2(cStruct: out)
        }
    }

    public func getQueueFamilyProperties2() -> Array<QueueFamilyProperties2> {
        enumerate { pQueueFamilyProperties, pQueueFamilyPropertyCount in
            self.instance.dispatchTable.vkGetPhysicalDeviceQueueFamilyProperties2(self.handle, pQueueFamilyPropertyCount, pQueueFamilyProperties)
        }.map { QueueFamilyProperties2(cStruct: $0) }
    }

    public func getMemoryProperties2() -> PhysicalDeviceMemoryProperties2 {
        var out = VkPhysicalDeviceMemoryProperties2()
        self.instance.dispatchTable.vkGetPhysicalDeviceMemoryProperties2(self.handle, &out)
        return PhysicalDeviceMemoryProperties2(cStruct: out)
    }

    public func getSparseImageFormatProperties2(formatInfo: PhysicalDeviceSparseImageFormatInfo2) -> Array<SparseImageFormatProperties2> {
        formatInfo.withCStruct { ptr_formatInfo in
            enumerate { pProperties, pPropertyCount in
                self.instance.dispatchTable.vkGetPhysicalDeviceSparseImageFormatProperties2(self.handle, ptr_formatInfo, pPropertyCount, pProperties)
            }.map { SparseImageFormatProperties2(cStruct: $0) }
        }
    }

    public func getExternalBufferProperties(externalBufferInfo: PhysicalDeviceExternalBufferInfo) -> ExternalBufferProperties {
        externalBufferInfo.withCStruct { ptr_externalBufferInfo in
            var out = VkExternalBufferProperties()
            self.instance.dispatchTable.vkGetPhysicalDeviceExternalBufferProperties(self.handle, ptr_externalBufferInfo, &out)
            return ExternalBufferProperties(cStruct: out)
        }
    }

    public func getExternalSemaphoreProperties(externalSemaphoreInfo: PhysicalDeviceExternalSemaphoreInfo) -> ExternalSemaphoreProperties {
        externalSemaphoreInfo.withCStruct { ptr_externalSemaphoreInfo in
            var out = VkExternalSemaphoreProperties()
            self.instance.dispatchTable.vkGetPhysicalDeviceExternalSemaphoreProperties(self.handle, ptr_externalSemaphoreInfo, &out)
            return ExternalSemaphoreProperties(cStruct: out)
        }
    }

    public func getExternalFenceProperties(externalFenceInfo: PhysicalDeviceExternalFenceInfo) -> ExternalFenceProperties {
        externalFenceInfo.withCStruct { ptr_externalFenceInfo in
            var out = VkExternalFenceProperties()
            self.instance.dispatchTable.vkGetPhysicalDeviceExternalFenceProperties(self.handle, ptr_externalFenceInfo, &out)
            return ExternalFenceProperties(cStruct: out)
        }
    }

    public func getSurfaceCapabilities2EXT(surface: SurfaceKHR) throws -> SurfaceCapabilities2EXT {
        var out = VkSurfaceCapabilities2EXT()
        try checkResult(
            self.instance.dispatchTable.vkGetPhysicalDeviceSurfaceCapabilities2EXT(self.handle, surface.handle, &out)
        )
        return SurfaceCapabilities2EXT(cStruct: out)
    }

    public func getPresentRectanglesKHR(surface: SurfaceKHR) throws -> Array<Rect2D> {
        try enumerate { pRects, pRectCount in
            self.instance.dispatchTable.vkGetPhysicalDevicePresentRectanglesKHR(self.handle, surface.handle, pRectCount, pRects)
        }.map { Rect2D(cStruct: $0) }
    }

    public func getMultisamplePropertiesEXT(samples: SampleCountFlags) -> MultisamplePropertiesEXT {
        var out = VkMultisamplePropertiesEXT()
        self.instance.dispatchTable.vkGetPhysicalDeviceMultisamplePropertiesEXT(self.handle, VkSampleCountFlagBits(rawValue: samples.rawValue), &out)
        return MultisamplePropertiesEXT(cStruct: out)
    }

    public func getSurfaceCapabilities2KHR(surfaceInfo: PhysicalDeviceSurfaceInfo2KHR) throws -> SurfaceCapabilities2KHR {
        try surfaceInfo.withCStruct { ptr_surfaceInfo in
            var out = VkSurfaceCapabilities2KHR()
            try checkResult(
                self.instance.dispatchTable.vkGetPhysicalDeviceSurfaceCapabilities2KHR(self.handle, ptr_surfaceInfo, &out)
            )
            return SurfaceCapabilities2KHR(cStruct: out)
        }
    }

    public func getSurfaceFormats2KHR(surfaceInfo: PhysicalDeviceSurfaceInfo2KHR) throws -> Array<SurfaceFormat2KHR> {
        try surfaceInfo.withCStruct { ptr_surfaceInfo in
            try enumerate { pSurfaceFormats, pSurfaceFormatCount in
                self.instance.dispatchTable.vkGetPhysicalDeviceSurfaceFormats2KHR(self.handle, ptr_surfaceInfo, pSurfaceFormatCount, pSurfaceFormats)
            }.map { SurfaceFormat2KHR(cStruct: $0) }
        }
    }

    public func getDisplayProperties2KHR() throws -> Array<DisplayProperties2KHR> {
        try enumerate { pProperties, pPropertyCount in
            self.instance.dispatchTable.vkGetPhysicalDeviceDisplayProperties2KHR(self.handle, pPropertyCount, pProperties)
        }.map { DisplayProperties2KHR(cStruct: $0, physicalDevice: self) }
    }

    public func getDisplayPlaneProperties2KHR() throws -> Array<DisplayPlaneProperties2KHR> {
        try enumerate { pProperties, pPropertyCount in
            self.instance.dispatchTable.vkGetPhysicalDeviceDisplayPlaneProperties2KHR(self.handle, pPropertyCount, pProperties)
        }.map { DisplayPlaneProperties2KHR(cStruct: $0, physicalDevice: self) }
    }

    public func getDisplayPlaneCapabilities2KHR(displayPlaneInfo: DisplayPlaneInfo2KHR) throws -> DisplayPlaneCapabilities2KHR {
        try displayPlaneInfo.withCStruct { ptr_displayPlaneInfo in
            var out = VkDisplayPlaneCapabilities2KHR()
            try checkResult(
                self.instance.dispatchTable.vkGetDisplayPlaneCapabilities2KHR(self.handle, ptr_displayPlaneInfo, &out)
            )
            return DisplayPlaneCapabilities2KHR(cStruct: out)
        }
    }

    public func getCalibrateableTimeDomainsEXT() throws -> Array<TimeDomainEXT> {
        try enumerate { pTimeDomains, pTimeDomainCount in
            self.instance.dispatchTable.vkGetPhysicalDeviceCalibrateableTimeDomainsEXT(self.handle, pTimeDomainCount, pTimeDomains)
        }.map { TimeDomainEXT(rawValue: $0.rawValue)! }
    }

    public func getCooperativeMatrixPropertiesNV() throws -> Array<CooperativeMatrixPropertiesNV> {
        try enumerate { pProperties, pPropertyCount in
            self.instance.dispatchTable.vkGetPhysicalDeviceCooperativeMatrixPropertiesNV(self.handle, pPropertyCount, pProperties)
        }.map { CooperativeMatrixPropertiesNV(cStruct: $0) }
    }

    public func getQueueFamilyPerformanceQueryCountersKHR(queueFamilyIndex: UInt32, counterCount: UnsafeMutablePointer<UInt32>, counters: UnsafeMutablePointer<VkPerformanceCounterKHR>?, counterDescriptions: UnsafeMutablePointer<VkPerformanceCounterDescriptionKHR>?) throws -> Void {
        try checkResult(
            self.instance.dispatchTable.vkEnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR(self.handle, queueFamilyIndex, counterCount, counters, counterDescriptions)
        )
    }

    public func getQueueFamilyPerformanceQueryPassesKHR(performanceQueryCreateInfo: QueryPoolPerformanceCreateInfoKHR) -> UInt32 {
        performanceQueryCreateInfo.withCStruct { ptr_performanceQueryCreateInfo in
            var out = UInt32()
            self.instance.dispatchTable.vkGetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR(self.handle, ptr_performanceQueryCreateInfo, &out)
            return out
        }
    }

    public func getSupportedFramebufferMixedSamplesCombinationsNV() throws -> Array<FramebufferMixedSamplesCombinationNV> {
        try enumerate { pCombinations, pCombinationCount in
            self.instance.dispatchTable.vkGetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV(self.handle, pCombinationCount, pCombinations)
        }.map { FramebufferMixedSamplesCombinationNV(cStruct: $0) }
    }

    public func getToolPropertiesEXT() throws -> Array<PhysicalDeviceToolPropertiesEXT> {
        try enumerate { pToolProperties, pToolCount in
            self.instance.dispatchTable.vkGetPhysicalDeviceToolPropertiesEXT(self.handle, pToolCount, pToolProperties)
        }.map { PhysicalDeviceToolPropertiesEXT(cStruct: $0) }
    }
}

public class Device: _HandleContainer {
    let handle: VkDevice?
    public let physicalDevice: PhysicalDevice
    let dispatchTable: DeviceDispatchTable

    public init(handle: VkDevice!, physicalDevice: PhysicalDevice) {
        self.handle = handle
        self.physicalDevice = physicalDevice
        self.dispatchTable = DeviceDispatchTable(vkGetDeviceProcAddr: self.physicalDevice.instance.dispatchTable.vkGetDeviceProcAddr, device: handle)
    }

    public func getProcAddr(name: String) -> PFN_vkVoidFunction? {
        name.withCString { cString_name in
            self.physicalDevice.instance.dispatchTable.vkGetDeviceProcAddr(self.handle, cString_name)
        }
    }

    public func destroy() -> Void {
        self.dispatchTable.vkDestroyDevice(self.handle, nil)
    }

    public func getQueue(queueFamilyIndex: UInt32, queueIndex: UInt32) -> Queue {
        var out: VkQueue!
        self.dispatchTable.vkGetDeviceQueue(self.handle, queueFamilyIndex, queueIndex, &out)
        return Queue(handle: out, device: self)
    }

    public func waitIdle() throws -> Void {
        try checkResult(
            self.dispatchTable.vkDeviceWaitIdle(self.handle)
        )
    }

    public func allocateMemory(allocateInfo: MemoryAllocateInfo) throws -> DeviceMemory {
        try allocateInfo.withCStruct { ptr_allocateInfo in
            var out: VkDeviceMemory!
            try checkResult(
                self.dispatchTable.vkAllocateMemory(self.handle, ptr_allocateInfo, nil, &out)
            )
            return DeviceMemory(handle: out, device: self)
        }
    }

    public func flushMappedMemoryRanges(memoryRanges: Array<MappedMemoryRange>) throws -> Void {
        try memoryRanges.withCStructBufferPointer { ptr_memoryRanges in
            try checkResult(
                self.dispatchTable.vkFlushMappedMemoryRanges(self.handle, UInt32(ptr_memoryRanges.count), ptr_memoryRanges.baseAddress)
            )
        }
    }

    public func invalidateMappedMemoryRanges(memoryRanges: Array<MappedMemoryRange>) throws -> Void {
        try memoryRanges.withCStructBufferPointer { ptr_memoryRanges in
            try checkResult(
                self.dispatchTable.vkInvalidateMappedMemoryRanges(self.handle, UInt32(ptr_memoryRanges.count), ptr_memoryRanges.baseAddress)
            )
        }
    }

    public func createFence(createInfo: FenceCreateInfo) throws -> Fence {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkFence!
            try checkResult(
                self.dispatchTable.vkCreateFence(self.handle, ptr_createInfo, nil, &out)
            )
            return Fence(handle: out, device: self)
        }
    }

    public func resetFences(fences: Array<Fence>) throws -> Void {
        try fences.map{ $0.handle }.withUnsafeBufferPointer { ptr_fences in
            try checkResult(
                self.dispatchTable.vkResetFences(self.handle, UInt32(ptr_fences.count), ptr_fences.baseAddress)
            )
        }
    }

    public func waitForFences(fences: Array<Fence>, waitAll: Bool, timeout: UInt64) throws -> Void {
        try fences.map{ $0.handle }.withUnsafeBufferPointer { ptr_fences in
            try checkResult(
                self.dispatchTable.vkWaitForFences(self.handle, UInt32(ptr_fences.count), ptr_fences.baseAddress, VkBool32(waitAll ? VK_TRUE : VK_FALSE), timeout)
            )
        }
    }

    public func createSemaphore(createInfo: SemaphoreCreateInfo) throws -> Semaphore {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkSemaphore!
            try checkResult(
                self.dispatchTable.vkCreateSemaphore(self.handle, ptr_createInfo, nil, &out)
            )
            return Semaphore(handle: out, device: self)
        }
    }

    public func createEvent(createInfo: EventCreateInfo) throws -> Event {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkEvent!
            try checkResult(
                self.dispatchTable.vkCreateEvent(self.handle, ptr_createInfo, nil, &out)
            )
            return Event(handle: out, device: self)
        }
    }

    public func createQueryPool(createInfo: QueryPoolCreateInfo) throws -> QueryPool {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkQueryPool!
            try checkResult(
                self.dispatchTable.vkCreateQueryPool(self.handle, ptr_createInfo, nil, &out)
            )
            return QueryPool(handle: out, device: self)
        }
    }

    public func createBuffer(createInfo: BufferCreateInfo) throws -> Buffer {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkBuffer!
            try checkResult(
                self.dispatchTable.vkCreateBuffer(self.handle, ptr_createInfo, nil, &out)
            )
            return Buffer(handle: out, device: self)
        }
    }

    public func createBufferView(createInfo: BufferViewCreateInfo) throws -> BufferView {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkBufferView!
            try checkResult(
                self.dispatchTable.vkCreateBufferView(self.handle, ptr_createInfo, nil, &out)
            )
            return BufferView(handle: out, device: self)
        }
    }

    public func createImage(createInfo: ImageCreateInfo) throws -> Image {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkImage!
            try checkResult(
                self.dispatchTable.vkCreateImage(self.handle, ptr_createInfo, nil, &out)
            )
            return Image(handle: out, device: self)
        }
    }

    public func createImageView(createInfo: ImageViewCreateInfo) throws -> ImageView {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkImageView!
            try checkResult(
                self.dispatchTable.vkCreateImageView(self.handle, ptr_createInfo, nil, &out)
            )
            return ImageView(handle: out, device: self)
        }
    }

    public func createShaderModule(createInfo: ShaderModuleCreateInfo) throws -> ShaderModule {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkShaderModule!
            try checkResult(
                self.dispatchTable.vkCreateShaderModule(self.handle, ptr_createInfo, nil, &out)
            )
            return ShaderModule(handle: out, device: self)
        }
    }

    public func createPipelineCache(createInfo: PipelineCacheCreateInfo) throws -> PipelineCache {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkPipelineCache!
            try checkResult(
                self.dispatchTable.vkCreatePipelineCache(self.handle, ptr_createInfo, nil, &out)
            )
            return PipelineCache(handle: out, device: self)
        }
    }

    public func createGraphicsPipelines(pipelineCache: PipelineCache?, createInfos: Array<GraphicsPipelineCreateInfo>) throws -> Array<Pipeline> {
        try createInfos.withCStructBufferPointer { ptr_createInfos in
            try Array<VkPipeline?>(unsafeUninitializedCapacity: Int(UInt32(ptr_createInfos.count))) { out, initializedCount in
                try checkResult(
                    self.dispatchTable.vkCreateGraphicsPipelines(self.handle, pipelineCache?.handle, UInt32(ptr_createInfos.count), ptr_createInfos.baseAddress, nil, out.baseAddress)
                )
                initializedCount = out.count
            }.map { Pipeline(handle: $0, device: self) }
        }
    }

    public func createComputePipelines(pipelineCache: PipelineCache?, createInfos: Array<ComputePipelineCreateInfo>) throws -> Array<Pipeline> {
        try createInfos.withCStructBufferPointer { ptr_createInfos in
            try Array<VkPipeline?>(unsafeUninitializedCapacity: Int(UInt32(ptr_createInfos.count))) { out, initializedCount in
                try checkResult(
                    self.dispatchTable.vkCreateComputePipelines(self.handle, pipelineCache?.handle, UInt32(ptr_createInfos.count), ptr_createInfos.baseAddress, nil, out.baseAddress)
                )
                initializedCount = out.count
            }.map { Pipeline(handle: $0, device: self) }
        }
    }

    public func createPipelineLayout(createInfo: PipelineLayoutCreateInfo) throws -> PipelineLayout {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkPipelineLayout!
            try checkResult(
                self.dispatchTable.vkCreatePipelineLayout(self.handle, ptr_createInfo, nil, &out)
            )
            return PipelineLayout(handle: out, device: self)
        }
    }

    public func createSampler(createInfo: SamplerCreateInfo) throws -> Sampler {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkSampler!
            try checkResult(
                self.dispatchTable.vkCreateSampler(self.handle, ptr_createInfo, nil, &out)
            )
            return Sampler(handle: out, device: self)
        }
    }

    public func createDescriptorSetLayout(createInfo: DescriptorSetLayoutCreateInfo) throws -> DescriptorSetLayout {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkDescriptorSetLayout!
            try checkResult(
                self.dispatchTable.vkCreateDescriptorSetLayout(self.handle, ptr_createInfo, nil, &out)
            )
            return DescriptorSetLayout(handle: out, device: self)
        }
    }

    public func createDescriptorPool(createInfo: DescriptorPoolCreateInfo) throws -> DescriptorPool {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkDescriptorPool!
            try checkResult(
                self.dispatchTable.vkCreateDescriptorPool(self.handle, ptr_createInfo, nil, &out)
            )
            return DescriptorPool(handle: out, device: self)
        }
    }

    public func allocateDescriptorSets(allocateInfo: DescriptorSetAllocateInfo) throws -> Array<DescriptorSet> {
        try allocateInfo.withCStruct { ptr_allocateInfo in
            try Array<VkDescriptorSet?>(unsafeUninitializedCapacity: Int(ptr_allocateInfo.pointee.descriptorSetCount)) { out, initializedCount in
                try checkResult(
                    self.dispatchTable.vkAllocateDescriptorSets(self.handle, ptr_allocateInfo, out.baseAddress)
                )
                initializedCount = out.count
            }.map { DescriptorSet(handle: $0, descriptorPool: allocateInfo.descriptorPool) }
        }
    }

    public func updateDescriptorSets(descriptorWrites: Array<WriteDescriptorSet>, descriptorCopies: Array<CopyDescriptorSet>) -> Void {
        descriptorWrites.withCStructBufferPointer { ptr_descriptorWrites in
            descriptorCopies.withCStructBufferPointer { ptr_descriptorCopies in
                self.dispatchTable.vkUpdateDescriptorSets(self.handle, UInt32(ptr_descriptorWrites.count), ptr_descriptorWrites.baseAddress, UInt32(ptr_descriptorCopies.count), ptr_descriptorCopies.baseAddress)
            }
        }
    }

    public func createFramebuffer(createInfo: FramebufferCreateInfo) throws -> Framebuffer {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkFramebuffer!
            try checkResult(
                self.dispatchTable.vkCreateFramebuffer(self.handle, ptr_createInfo, nil, &out)
            )
            return Framebuffer(handle: out, device: self)
        }
    }

    public func createRenderPass(createInfo: RenderPassCreateInfo) throws -> RenderPass {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkRenderPass!
            try checkResult(
                self.dispatchTable.vkCreateRenderPass(self.handle, ptr_createInfo, nil, &out)
            )
            return RenderPass(handle: out, device: self)
        }
    }

    public func createCommandPool(createInfo: CommandPoolCreateInfo) throws -> CommandPool {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkCommandPool!
            try checkResult(
                self.dispatchTable.vkCreateCommandPool(self.handle, ptr_createInfo, nil, &out)
            )
            return CommandPool(handle: out, device: self)
        }
    }

    public func allocateCommandBuffers(allocateInfo: CommandBufferAllocateInfo) throws -> Array<CommandBuffer> {
        try allocateInfo.withCStruct { ptr_allocateInfo in
            try Array<VkCommandBuffer?>(unsafeUninitializedCapacity: Int(ptr_allocateInfo.pointee.commandBufferCount)) { out, initializedCount in
                try checkResult(
                    self.dispatchTable.vkAllocateCommandBuffers(self.handle, ptr_allocateInfo, out.baseAddress)
                )
                initializedCount = out.count
            }.map { CommandBuffer(handle: $0, commandPool: allocateInfo.commandPool) }
        }
    }

    public func createSharedSwapchainsKHR(createInfos: Array<SwapchainCreateInfoKHR>) throws -> Array<SwapchainKHR> {
        try createInfos.withCStructBufferPointer { ptr_createInfos in
            try Array<VkSwapchainKHR?>(unsafeUninitializedCapacity: Int(UInt32(ptr_createInfos.count))) { out, initializedCount in
                try checkResult(
                    self.dispatchTable.vkCreateSharedSwapchainsKHR(self.handle, UInt32(ptr_createInfos.count), ptr_createInfos.baseAddress, nil, out.baseAddress)
                )
                initializedCount = out.count
            }.map { SwapchainKHR(handle: $0, device: self) }
        }
    }

    public func createSwapchainKHR(createInfo: SwapchainCreateInfoKHR) throws -> SwapchainKHR {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkSwapchainKHR!
            try checkResult(
                self.dispatchTable.vkCreateSwapchainKHR(self.handle, ptr_createInfo, nil, &out)
            )
            return SwapchainKHR(handle: out, device: self)
        }
    }

    public func debugMarkerSetObjectNameEXT(nameInfo: DebugMarkerObjectNameInfoEXT) throws -> Void {
        try nameInfo.withCStruct { ptr_nameInfo in
            try checkResult(
                self.dispatchTable.vkDebugMarkerSetObjectNameEXT(self.handle, ptr_nameInfo)
            )
        }
    }

    public func debugMarkerSetObjectTagEXT(tagInfo: DebugMarkerObjectTagInfoEXT) throws -> Void {
        try tagInfo.withCStruct { ptr_tagInfo in
            try checkResult(
                self.dispatchTable.vkDebugMarkerSetObjectTagEXT(self.handle, ptr_tagInfo)
            )
        }
    }

    public func getGeneratedCommandsMemoryRequirementsNV(info: GeneratedCommandsMemoryRequirementsInfoNV) -> MemoryRequirements2 {
        info.withCStruct { ptr_info in
            var out = VkMemoryRequirements2()
            self.dispatchTable.vkGetGeneratedCommandsMemoryRequirementsNV(self.handle, ptr_info, &out)
            return MemoryRequirements2(cStruct: out)
        }
    }

    public func createIndirectCommandsLayoutNV(createInfo: IndirectCommandsLayoutCreateInfoNV) throws -> IndirectCommandsLayoutNV {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkIndirectCommandsLayoutNV!
            try checkResult(
                self.dispatchTable.vkCreateIndirectCommandsLayoutNV(self.handle, ptr_createInfo, nil, &out)
            )
            return IndirectCommandsLayoutNV(handle: out, device: self)
        }
    }

    public func getMemoryFdKHR(getFdInfo: MemoryGetFdInfoKHR) throws -> Int32 {
        try getFdInfo.withCStruct { ptr_getFdInfo in
            var out = Int32()
            try checkResult(
                self.dispatchTable.vkGetMemoryFdKHR(self.handle, ptr_getFdInfo, &out)
            )
            return out
        }
    }

    public func getMemoryFdPropertiesKHR(handleType: ExternalMemoryHandleTypeFlags, fd: Int32) throws -> MemoryFdPropertiesKHR {
        var out = VkMemoryFdPropertiesKHR()
        try checkResult(
            self.dispatchTable.vkGetMemoryFdPropertiesKHR(self.handle, VkExternalMemoryHandleTypeFlagBits(rawValue: handleType.rawValue), fd, &out)
        )
        return MemoryFdPropertiesKHR(cStruct: out)
    }

    public func getSemaphoreFdKHR(getFdInfo: SemaphoreGetFdInfoKHR) throws -> Int32 {
        try getFdInfo.withCStruct { ptr_getFdInfo in
            var out = Int32()
            try checkResult(
                self.dispatchTable.vkGetSemaphoreFdKHR(self.handle, ptr_getFdInfo, &out)
            )
            return out
        }
    }

    public func importSemaphoreFdKHR(importSemaphoreFdInfo: ImportSemaphoreFdInfoKHR) throws -> Void {
        try importSemaphoreFdInfo.withCStruct { ptr_importSemaphoreFdInfo in
            try checkResult(
                self.dispatchTable.vkImportSemaphoreFdKHR(self.handle, ptr_importSemaphoreFdInfo)
            )
        }
    }

    public func getFenceFdKHR(getFdInfo: FenceGetFdInfoKHR) throws -> Int32 {
        try getFdInfo.withCStruct { ptr_getFdInfo in
            var out = Int32()
            try checkResult(
                self.dispatchTable.vkGetFenceFdKHR(self.handle, ptr_getFdInfo, &out)
            )
            return out
        }
    }

    public func importFenceFdKHR(importFenceFdInfo: ImportFenceFdInfoKHR) throws -> Void {
        try importFenceFdInfo.withCStruct { ptr_importFenceFdInfo in
            try checkResult(
                self.dispatchTable.vkImportFenceFdKHR(self.handle, ptr_importFenceFdInfo)
            )
        }
    }

    public func displayPowerControlEXT(display: DisplayKHR, displayPowerInfo: DisplayPowerInfoEXT) throws -> Void {
        try displayPowerInfo.withCStruct { ptr_displayPowerInfo in
            try checkResult(
                self.dispatchTable.vkDisplayPowerControlEXT(self.handle, display.handle, ptr_displayPowerInfo)
            )
        }
    }

    public func registerEventEXT(deviceEventInfo: DeviceEventInfoEXT) throws -> Fence {
        try deviceEventInfo.withCStruct { ptr_deviceEventInfo in
            var out: VkFence!
            try checkResult(
                self.dispatchTable.vkRegisterDeviceEventEXT(self.handle, ptr_deviceEventInfo, nil, &out)
            )
            return Fence(handle: out, device: self)
        }
    }

    public func registerDisplayEventEXT(display: DisplayKHR, displayEventInfo: DisplayEventInfoEXT) throws -> Fence {
        try displayEventInfo.withCStruct { ptr_displayEventInfo in
            var out: VkFence!
            try checkResult(
                self.dispatchTable.vkRegisterDisplayEventEXT(self.handle, display.handle, ptr_displayEventInfo, nil, &out)
            )
            return Fence(handle: out, device: self)
        }
    }

    public func getGroupPeerMemoryFeatures(heapIndex: UInt32, localDeviceIndex: UInt32, remoteDeviceIndex: UInt32) -> PeerMemoryFeatureFlags {
        var out = VkPeerMemoryFeatureFlags()
        self.dispatchTable.vkGetDeviceGroupPeerMemoryFeatures(self.handle, heapIndex, localDeviceIndex, remoteDeviceIndex, &out)
        return PeerMemoryFeatureFlags(rawValue: out)
    }

    public func bindBufferMemory2(bindInfos: Array<BindBufferMemoryInfo>) throws -> Void {
        try bindInfos.withCStructBufferPointer { ptr_bindInfos in
            try checkResult(
                self.dispatchTable.vkBindBufferMemory2(self.handle, UInt32(ptr_bindInfos.count), ptr_bindInfos.baseAddress)
            )
        }
    }

    public func bindImageMemory2(bindInfos: Array<BindImageMemoryInfo>) throws -> Void {
        try bindInfos.withCStructBufferPointer { ptr_bindInfos in
            try checkResult(
                self.dispatchTable.vkBindImageMemory2(self.handle, UInt32(ptr_bindInfos.count), ptr_bindInfos.baseAddress)
            )
        }
    }

    public func getGroupPresentCapabilitiesKHR() throws -> DeviceGroupPresentCapabilitiesKHR {
        var out = VkDeviceGroupPresentCapabilitiesKHR()
        try checkResult(
            self.dispatchTable.vkGetDeviceGroupPresentCapabilitiesKHR(self.handle, &out)
        )
        return DeviceGroupPresentCapabilitiesKHR(cStruct: out)
    }

    public func getGroupSurfacePresentModesKHR(surface: SurfaceKHR) throws -> DeviceGroupPresentModeFlagsKHR {
        var out = VkDeviceGroupPresentModeFlagsKHR()
        try checkResult(
            self.dispatchTable.vkGetDeviceGroupSurfacePresentModesKHR(self.handle, surface.handle, &out)
        )
        return DeviceGroupPresentModeFlagsKHR(rawValue: out)
    }

    public func acquireNextImage2KHR(acquireInfo: AcquireNextImageInfoKHR) throws -> UInt32 {
        try acquireInfo.withCStruct { ptr_acquireInfo in
            var out = UInt32()
            try checkResult(
                self.dispatchTable.vkAcquireNextImage2KHR(self.handle, ptr_acquireInfo, &out)
            )
            return out
        }
    }

    public func createDescriptorUpdateTemplate(createInfo: DescriptorUpdateTemplateCreateInfo) throws -> DescriptorUpdateTemplate {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkDescriptorUpdateTemplate!
            try checkResult(
                self.dispatchTable.vkCreateDescriptorUpdateTemplate(self.handle, ptr_createInfo, nil, &out)
            )
            return DescriptorUpdateTemplate(handle: out, device: self)
        }
    }

    public func setHdrMetadataEXT(swapchains: Array<SwapchainKHR>, metadata: Array<HdrMetadataEXT>) -> Void {
        swapchains.map{ $0.handle }.withUnsafeBufferPointer { ptr_swapchains in
            metadata.withCStructBufferPointer { ptr_metadata in
                self.dispatchTable.vkSetHdrMetadataEXT(self.handle, UInt32(ptr_swapchains.count), ptr_swapchains.baseAddress, ptr_metadata.baseAddress)
            }
        }
    }

    public func getBufferMemoryRequirements2(info: BufferMemoryRequirementsInfo2) -> MemoryRequirements2 {
        info.withCStruct { ptr_info in
            var out = VkMemoryRequirements2()
            self.dispatchTable.vkGetBufferMemoryRequirements2(self.handle, ptr_info, &out)
            return MemoryRequirements2(cStruct: out)
        }
    }

    public func getImageMemoryRequirements2(info: ImageMemoryRequirementsInfo2) -> MemoryRequirements2 {
        info.withCStruct { ptr_info in
            var out = VkMemoryRequirements2()
            self.dispatchTable.vkGetImageMemoryRequirements2(self.handle, ptr_info, &out)
            return MemoryRequirements2(cStruct: out)
        }
    }

    public func getImageSparseMemoryRequirements2(info: ImageSparseMemoryRequirementsInfo2) -> Array<SparseImageMemoryRequirements2> {
        info.withCStruct { ptr_info in
            enumerate { pSparseMemoryRequirements, pSparseMemoryRequirementCount in
                self.dispatchTable.vkGetImageSparseMemoryRequirements2(self.handle, ptr_info, pSparseMemoryRequirementCount, pSparseMemoryRequirements)
            }.map { SparseImageMemoryRequirements2(cStruct: $0) }
        }
    }

    public func createSamplerYcbcrConversion(createInfo: SamplerYcbcrConversionCreateInfo) throws -> SamplerYcbcrConversion {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkSamplerYcbcrConversion!
            try checkResult(
                self.dispatchTable.vkCreateSamplerYcbcrConversion(self.handle, ptr_createInfo, nil, &out)
            )
            return SamplerYcbcrConversion(handle: out, device: self)
        }
    }

    public func getQueue2(queueInfo: DeviceQueueInfo2) -> Queue {
        queueInfo.withCStruct { ptr_queueInfo in
            var out: VkQueue!
            self.dispatchTable.vkGetDeviceQueue2(self.handle, ptr_queueInfo, &out)
            return Queue(handle: out, device: self)
        }
    }

    public func createValidationCacheEXT(createInfo: ValidationCacheCreateInfoEXT) throws -> ValidationCacheEXT {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkValidationCacheEXT!
            try checkResult(
                self.dispatchTable.vkCreateValidationCacheEXT(self.handle, ptr_createInfo, nil, &out)
            )
            return ValidationCacheEXT(handle: out, device: self)
        }
    }

    public func getDescriptorSetLayoutSupport(createInfo: DescriptorSetLayoutCreateInfo) -> DescriptorSetLayoutSupport {
        createInfo.withCStruct { ptr_createInfo in
            var out = VkDescriptorSetLayoutSupport()
            self.dispatchTable.vkGetDescriptorSetLayoutSupport(self.handle, ptr_createInfo, &out)
            return DescriptorSetLayoutSupport(cStruct: out)
        }
    }

    public func getCalibratedTimestampsEXT(timestampInfos: Array<CalibratedTimestampInfoEXT>, timestamps: UnsafeMutablePointer<UInt64>, maxDeviation: UnsafeMutablePointer<UInt64>) throws -> Void {
        try timestampInfos.withCStructBufferPointer { ptr_timestampInfos in
            try checkResult(
                self.dispatchTable.vkGetCalibratedTimestampsEXT(self.handle, UInt32(ptr_timestampInfos.count), ptr_timestampInfos.baseAddress, timestamps, maxDeviation)
            )
        }
    }

    public func setDebugUtilsObjectNameEXT(nameInfo: DebugUtilsObjectNameInfoEXT) throws -> Void {
        try nameInfo.withCStruct { ptr_nameInfo in
            try checkResult(
                self.dispatchTable.vkSetDebugUtilsObjectNameEXT(self.handle, ptr_nameInfo)
            )
        }
    }

    public func setDebugUtilsObjectTagEXT(tagInfo: DebugUtilsObjectTagInfoEXT) throws -> Void {
        try tagInfo.withCStruct { ptr_tagInfo in
            try checkResult(
                self.dispatchTable.vkSetDebugUtilsObjectTagEXT(self.handle, ptr_tagInfo)
            )
        }
    }

    public func getMemoryHostPointerPropertiesEXT(handleType: ExternalMemoryHandleTypeFlags, hostPointer: UnsafeRawPointer) throws -> MemoryHostPointerPropertiesEXT {
        var out = VkMemoryHostPointerPropertiesEXT()
        try checkResult(
            self.dispatchTable.vkGetMemoryHostPointerPropertiesEXT(self.handle, VkExternalMemoryHandleTypeFlagBits(rawValue: handleType.rawValue), hostPointer, &out)
        )
        return MemoryHostPointerPropertiesEXT(cStruct: out)
    }

    public func createRenderPass2(createInfo: RenderPassCreateInfo2) throws -> RenderPass {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkRenderPass!
            try checkResult(
                self.dispatchTable.vkCreateRenderPass2(self.handle, ptr_createInfo, nil, &out)
            )
            return RenderPass(handle: out, device: self)
        }
    }

    public func waitSemaphores(waitInfo: SemaphoreWaitInfo, timeout: UInt64) throws -> Void {
        try waitInfo.withCStruct { ptr_waitInfo in
            try checkResult(
                self.dispatchTable.vkWaitSemaphores(self.handle, ptr_waitInfo, timeout)
            )
        }
    }

    public func signalSemaphore(signalInfo: SemaphoreSignalInfo) throws -> Void {
        try signalInfo.withCStruct { ptr_signalInfo in
            try checkResult(
                self.dispatchTable.vkSignalSemaphore(self.handle, ptr_signalInfo)
            )
        }
    }

    public func createAccelerationStructureNV(createInfo: AccelerationStructureCreateInfoNV) throws -> AccelerationStructureNV {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkAccelerationStructureNV!
            try checkResult(
                self.dispatchTable.vkCreateAccelerationStructureNV(self.handle, ptr_createInfo, nil, &out)
            )
            return AccelerationStructureNV(handle: out, device: self)
        }
    }

    public func getAccelerationStructureMemoryRequirementsNV(info: AccelerationStructureMemoryRequirementsInfoNV) -> VkMemoryRequirements2KHR {
        info.withCStruct { ptr_info in
            var out = VkMemoryRequirements2KHR()
            self.dispatchTable.vkGetAccelerationStructureMemoryRequirementsNV(self.handle, ptr_info, &out)
            return out
        }
    }

    public func createRayTracingPipelinesNV(pipelineCache: PipelineCache?, createInfos: Array<RayTracingPipelineCreateInfoNV>) throws -> Array<Pipeline> {
        try createInfos.withCStructBufferPointer { ptr_createInfos in
            try Array<VkPipeline?>(unsafeUninitializedCapacity: Int(UInt32(ptr_createInfos.count))) { out, initializedCount in
                try checkResult(
                    self.dispatchTable.vkCreateRayTracingPipelinesNV(self.handle, pipelineCache?.handle, UInt32(ptr_createInfos.count), ptr_createInfos.baseAddress, nil, out.baseAddress)
                )
                initializedCount = out.count
            }.map { Pipeline(handle: $0, device: self) }
        }
    }

    public func getImageViewHandleNVX(info: ImageViewHandleInfoNVX) -> UInt32 {
        info.withCStruct { ptr_info in
            self.dispatchTable.vkGetImageViewHandleNVX(self.handle, ptr_info)
        }
    }

    public func acquireProfilingLockKHR(info: AcquireProfilingLockInfoKHR) throws -> Void {
        try info.withCStruct { ptr_info in
            try checkResult(
                self.dispatchTable.vkAcquireProfilingLockKHR(self.handle, ptr_info)
            )
        }
    }

    public func releaseProfilingLockKHR() -> Void {
        self.dispatchTable.vkReleaseProfilingLockKHR(self.handle)
    }

    public func getBufferOpaqueCaptureAddress(info: BufferDeviceAddressInfo) -> UInt64 {
        info.withCStruct { ptr_info in
            self.dispatchTable.vkGetBufferOpaqueCaptureAddress(self.handle, ptr_info)
        }
    }

    public func getBufferAddress(info: BufferDeviceAddressInfo) -> VkDeviceAddress {
        info.withCStruct { ptr_info in
            self.dispatchTable.vkGetBufferDeviceAddress(self.handle, ptr_info)
        }
    }

    public func initializePerformanceApiINTEL(initializeInfo: InitializePerformanceApiInfoINTEL) throws -> Void {
        try initializeInfo.withCStruct { ptr_initializeInfo in
            try checkResult(
                self.dispatchTable.vkInitializePerformanceApiINTEL(self.handle, ptr_initializeInfo)
            )
        }
    }

    public func uninitializePerformanceApiINTEL() -> Void {
        self.dispatchTable.vkUninitializePerformanceApiINTEL(self.handle)
    }

    public func acquirePerformanceConfigurationINTEL(acquireInfo: PerformanceConfigurationAcquireInfoINTEL) throws -> PerformanceConfigurationINTEL {
        try acquireInfo.withCStruct { ptr_acquireInfo in
            var out: VkPerformanceConfigurationINTEL!
            try checkResult(
                self.dispatchTable.vkAcquirePerformanceConfigurationINTEL(self.handle, ptr_acquireInfo, &out)
            )
            return PerformanceConfigurationINTEL(handle: out, device: self)
        }
    }

    public func getPerformanceParameterINTEL(parameter: PerformanceParameterTypeINTEL) throws -> PerformanceValueINTEL {
        var out = VkPerformanceValueINTEL()
        try checkResult(
            self.dispatchTable.vkGetPerformanceParameterINTEL(self.handle, VkPerformanceParameterTypeINTEL(rawValue: parameter.rawValue), &out)
        )
        return PerformanceValueINTEL(cStruct: out)
    }

    public func getMemoryOpaqueCaptureAddress(info: DeviceMemoryOpaqueCaptureAddressInfo) -> UInt64 {
        info.withCStruct { ptr_info in
            self.dispatchTable.vkGetDeviceMemoryOpaqueCaptureAddress(self.handle, ptr_info)
        }
    }

    public func getPipelineExecutablePropertiesKHR(pipelineInfo: PipelineInfoKHR) throws -> Array<PipelineExecutablePropertiesKHR> {
        try pipelineInfo.withCStruct { ptr_pipelineInfo in
            try enumerate { pProperties, pExecutableCount in
                self.dispatchTable.vkGetPipelineExecutablePropertiesKHR(self.handle, ptr_pipelineInfo, pExecutableCount, pProperties)
            }.map { PipelineExecutablePropertiesKHR(cStruct: $0) }
        }
    }

    public func getPipelineExecutableStatisticsKHR(executableInfo: PipelineExecutableInfoKHR) throws -> Array<PipelineExecutableStatisticKHR> {
        try executableInfo.withCStruct { ptr_executableInfo in
            try enumerate { pStatistics, pStatisticCount in
                self.dispatchTable.vkGetPipelineExecutableStatisticsKHR(self.handle, ptr_executableInfo, pStatisticCount, pStatistics)
            }.map { PipelineExecutableStatisticKHR(cStruct: $0) }
        }
    }

    public func getPipelineExecutableInternalRepresentationsKHR(executableInfo: PipelineExecutableInfoKHR) throws -> Array<PipelineExecutableInternalRepresentationKHR> {
        try executableInfo.withCStruct { ptr_executableInfo in
            try enumerate { pInternalRepresentations, pInternalRepresentationCount in
                self.dispatchTable.vkGetPipelineExecutableInternalRepresentationsKHR(self.handle, ptr_executableInfo, pInternalRepresentationCount, pInternalRepresentations)
            }.map { PipelineExecutableInternalRepresentationKHR(cStruct: $0) }
        }
    }
}

public class Queue: _HandleContainer {
    let handle: VkQueue?
    public let device: Device

    public init(handle: VkQueue!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func submit(submits: Array<SubmitInfo>, fence: Fence?) throws -> Void {
        try submits.withCStructBufferPointer { ptr_submits in
            try checkResult(
                self.device.dispatchTable.vkQueueSubmit(self.handle, UInt32(ptr_submits.count), ptr_submits.baseAddress, fence?.handle)
            )
        }
    }

    public func waitIdle() throws -> Void {
        try checkResult(
            self.device.dispatchTable.vkQueueWaitIdle(self.handle)
        )
    }

    public func bindSparse(bindInfo: Array<BindSparseInfo>, fence: Fence?) throws -> Void {
        try bindInfo.withCStructBufferPointer { ptr_bindInfo in
            try checkResult(
                self.device.dispatchTable.vkQueueBindSparse(self.handle, UInt32(ptr_bindInfo.count), ptr_bindInfo.baseAddress, fence?.handle)
            )
        }
    }

    public func presentKHR(presentInfo: PresentInfoKHR) throws -> Void {
        try presentInfo.withCStruct { ptr_presentInfo in
            try checkResult(
                self.device.dispatchTable.vkQueuePresentKHR(self.handle, ptr_presentInfo)
            )
        }
    }

    public func beginDebugUtilsLabelEXT(labelInfo: DebugUtilsLabelEXT) -> Void {
        labelInfo.withCStruct { ptr_labelInfo in
            self.device.dispatchTable.vkQueueBeginDebugUtilsLabelEXT(self.handle, ptr_labelInfo)
        }
    }

    public func endDebugUtilsLabelEXT() -> Void {
        self.device.dispatchTable.vkQueueEndDebugUtilsLabelEXT(self.handle)
    }

    public func insertDebugUtilsLabelEXT(labelInfo: DebugUtilsLabelEXT) -> Void {
        labelInfo.withCStruct { ptr_labelInfo in
            self.device.dispatchTable.vkQueueInsertDebugUtilsLabelEXT(self.handle, ptr_labelInfo)
        }
    }

    public func getCheckpointDataNV() -> Array<CheckpointDataNV> {
        enumerate { pCheckpointData, pCheckpointDataCount in
            self.device.dispatchTable.vkGetQueueCheckpointDataNV(self.handle, pCheckpointDataCount, pCheckpointData)
        }.map { CheckpointDataNV(cStruct: $0) }
    }

    public func setPerformanceConfigurationINTEL(configuration: PerformanceConfigurationINTEL) throws -> Void {
        try checkResult(
            self.device.dispatchTable.vkQueueSetPerformanceConfigurationINTEL(self.handle, configuration.handle)
        )
    }
}

public class CommandPool: _HandleContainer {
    let handle: VkCommandPool?
    public let device: Device

    public init(handle: VkCommandPool!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroyCommandPool(self.device.handle, self.handle, nil)
    }

    public func reset(flags: CommandPoolResetFlags) throws -> Void {
        try checkResult(
            self.device.dispatchTable.vkResetCommandPool(self.device.handle, self.handle, flags.rawValue)
        )
    }

    public func freeCommandBuffers(commandBuffers: Array<CommandBuffer>) -> Void {
        commandBuffers.map{ $0.handle }.withUnsafeBufferPointer { ptr_commandBuffers in
            self.device.dispatchTable.vkFreeCommandBuffers(self.device.handle, self.handle, UInt32(ptr_commandBuffers.count), ptr_commandBuffers.baseAddress)
        }
    }

    public func trim(flags: CommandPoolTrimFlags) -> Void {
        self.device.dispatchTable.vkTrimCommandPool(self.device.handle, self.handle, flags.rawValue)
    }
}

public class CommandBuffer: _HandleContainer {
    let handle: VkCommandBuffer?
    public let commandPool: CommandPool

    public init(handle: VkCommandBuffer!, commandPool: CommandPool) {
        self.handle = handle
        self.commandPool = commandPool
    }

    public func begin(beginInfo: CommandBufferBeginInfo) throws -> Void {
        try beginInfo.withCStruct { ptr_beginInfo in
            try checkResult(
                self.commandPool.device.dispatchTable.vkBeginCommandBuffer(self.handle, ptr_beginInfo)
            )
        }
    }

    public func end() throws -> Void {
        try checkResult(
            self.commandPool.device.dispatchTable.vkEndCommandBuffer(self.handle)
        )
    }

    public func reset(flags: CommandBufferResetFlags) throws -> Void {
        try checkResult(
            self.commandPool.device.dispatchTable.vkResetCommandBuffer(self.handle, flags.rawValue)
        )
    }

    public func cmdBindPipeline(pipelineBindPoint: PipelineBindPoint, pipeline: Pipeline) -> Void {
        self.commandPool.device.dispatchTable.vkCmdBindPipeline(self.handle, VkPipelineBindPoint(rawValue: pipelineBindPoint.rawValue), pipeline.handle)
    }

    public func cmdSetViewport(firstViewport: UInt32, viewports: Array<Viewport>) -> Void {
        viewports.withCStructBufferPointer { ptr_viewports in
            self.commandPool.device.dispatchTable.vkCmdSetViewport(self.handle, firstViewport, UInt32(ptr_viewports.count), ptr_viewports.baseAddress)
        }
    }

    public func cmdSetScissor(firstScissor: UInt32, scissors: Array<Rect2D>) -> Void {
        scissors.withCStructBufferPointer { ptr_scissors in
            self.commandPool.device.dispatchTable.vkCmdSetScissor(self.handle, firstScissor, UInt32(ptr_scissors.count), ptr_scissors.baseAddress)
        }
    }

    public func cmdSetLineWidth(lineWidth: Float) -> Void {
        self.commandPool.device.dispatchTable.vkCmdSetLineWidth(self.handle, lineWidth)
    }

    public func cmdSetDepthBias(depthBiasConstantFactor: Float, depthBiasClamp: Float, depthBiasSlopeFactor: Float) -> Void {
        self.commandPool.device.dispatchTable.vkCmdSetDepthBias(self.handle, depthBiasConstantFactor, depthBiasClamp, depthBiasSlopeFactor)
    }

    public func cmdSetBlendConstants(blendConstants: (Float, Float, Float, Float)) -> Void {
        withUnsafeBytes(of: blendConstants) { ptr_blendConstants in
            self.commandPool.device.dispatchTable.vkCmdSetBlendConstants(self.handle, ptr_blendConstants.bindMemory(to: Float.self).baseAddress)
        }
    }

    public func cmdSetDepthBounds(minDepthBounds: Float, maxDepthBounds: Float) -> Void {
        self.commandPool.device.dispatchTable.vkCmdSetDepthBounds(self.handle, minDepthBounds, maxDepthBounds)
    }

    public func cmdSetStencilCompareMask(faceMask: StencilFaceFlags, compareMask: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdSetStencilCompareMask(self.handle, faceMask.rawValue, compareMask)
    }

    public func cmdSetStencilWriteMask(faceMask: StencilFaceFlags, writeMask: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdSetStencilWriteMask(self.handle, faceMask.rawValue, writeMask)
    }

    public func cmdSetStencilReference(faceMask: StencilFaceFlags, reference: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdSetStencilReference(self.handle, faceMask.rawValue, reference)
    }

    public func cmdBindDescriptorSets(pipelineBindPoint: PipelineBindPoint, layout: PipelineLayout, firstSet: UInt32, descriptorSets: Array<DescriptorSet>, dynamicOffsets: Array<UInt32>) -> Void {
        descriptorSets.map{ $0.handle }.withUnsafeBufferPointer { ptr_descriptorSets in
            dynamicOffsets.withUnsafeBufferPointer { ptr_dynamicOffsets in
                self.commandPool.device.dispatchTable.vkCmdBindDescriptorSets(self.handle, VkPipelineBindPoint(rawValue: pipelineBindPoint.rawValue), layout.handle, firstSet, UInt32(ptr_descriptorSets.count), ptr_descriptorSets.baseAddress, UInt32(ptr_dynamicOffsets.count), ptr_dynamicOffsets.baseAddress)
            }
        }
    }

    public func cmdBindIndexBuffer(buffer: Buffer, offset: VkDeviceSize, indexType: IndexType) -> Void {
        self.commandPool.device.dispatchTable.vkCmdBindIndexBuffer(self.handle, buffer.handle, offset, VkIndexType(rawValue: indexType.rawValue))
    }

    public func cmdBindVertexBuffers(firstBinding: UInt32, buffers: Array<Buffer>, offsets: Array<VkDeviceSize>) -> Void {
        buffers.map{ $0.handle }.withUnsafeBufferPointer { ptr_buffers in
            offsets.withUnsafeBufferPointer { ptr_offsets in
                self.commandPool.device.dispatchTable.vkCmdBindVertexBuffers(self.handle, firstBinding, UInt32(ptr_buffers.count), ptr_buffers.baseAddress, ptr_offsets.baseAddress)
            }
        }
    }

    public func cmdDraw(vertexCount: UInt32, instanceCount: UInt32, firstVertex: UInt32, firstInstance: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdDraw(self.handle, vertexCount, instanceCount, firstVertex, firstInstance)
    }

    public func cmdDrawIndexed(indexCount: UInt32, instanceCount: UInt32, firstIndex: UInt32, vertexOffset: Int32, firstInstance: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdDrawIndexed(self.handle, indexCount, instanceCount, firstIndex, vertexOffset, firstInstance)
    }

    public func cmdDrawIndirect(buffer: Buffer, offset: VkDeviceSize, drawCount: UInt32, stride: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdDrawIndirect(self.handle, buffer.handle, offset, drawCount, stride)
    }

    public func cmdDrawIndexedIndirect(buffer: Buffer, offset: VkDeviceSize, drawCount: UInt32, stride: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdDrawIndexedIndirect(self.handle, buffer.handle, offset, drawCount, stride)
    }

    public func cmdDispatch(groupCountX: UInt32, groupCountY: UInt32, groupCountZ: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdDispatch(self.handle, groupCountX, groupCountY, groupCountZ)
    }

    public func cmdDispatchIndirect(buffer: Buffer, offset: VkDeviceSize) -> Void {
        self.commandPool.device.dispatchTable.vkCmdDispatchIndirect(self.handle, buffer.handle, offset)
    }

    public func cmdCopyBuffer(srcBuffer: Buffer, dstBuffer: Buffer, regions: Array<BufferCopy>) -> Void {
        regions.withCStructBufferPointer { ptr_regions in
            self.commandPool.device.dispatchTable.vkCmdCopyBuffer(self.handle, srcBuffer.handle, dstBuffer.handle, UInt32(ptr_regions.count), ptr_regions.baseAddress)
        }
    }

    public func cmdCopyImage(srcImage: Image, srcImageLayout: ImageLayout, dstImage: Image, dstImageLayout: ImageLayout, regions: Array<ImageCopy>) -> Void {
        regions.withCStructBufferPointer { ptr_regions in
            self.commandPool.device.dispatchTable.vkCmdCopyImage(self.handle, srcImage.handle, VkImageLayout(rawValue: srcImageLayout.rawValue), dstImage.handle, VkImageLayout(rawValue: dstImageLayout.rawValue), UInt32(ptr_regions.count), ptr_regions.baseAddress)
        }
    }

    public func cmdBlitImage(srcImage: Image, srcImageLayout: ImageLayout, dstImage: Image, dstImageLayout: ImageLayout, regions: Array<ImageBlit>, filter: Filter) -> Void {
        regions.withCStructBufferPointer { ptr_regions in
            self.commandPool.device.dispatchTable.vkCmdBlitImage(self.handle, srcImage.handle, VkImageLayout(rawValue: srcImageLayout.rawValue), dstImage.handle, VkImageLayout(rawValue: dstImageLayout.rawValue), UInt32(ptr_regions.count), ptr_regions.baseAddress, VkFilter(rawValue: filter.rawValue))
        }
    }

    public func cmdCopyBufferToImage(srcBuffer: Buffer, dstImage: Image, dstImageLayout: ImageLayout, regions: Array<BufferImageCopy>) -> Void {
        regions.withCStructBufferPointer { ptr_regions in
            self.commandPool.device.dispatchTable.vkCmdCopyBufferToImage(self.handle, srcBuffer.handle, dstImage.handle, VkImageLayout(rawValue: dstImageLayout.rawValue), UInt32(ptr_regions.count), ptr_regions.baseAddress)
        }
    }

    public func cmdCopyImageToBuffer(srcImage: Image, srcImageLayout: ImageLayout, dstBuffer: Buffer, regions: Array<BufferImageCopy>) -> Void {
        regions.withCStructBufferPointer { ptr_regions in
            self.commandPool.device.dispatchTable.vkCmdCopyImageToBuffer(self.handle, srcImage.handle, VkImageLayout(rawValue: srcImageLayout.rawValue), dstBuffer.handle, UInt32(ptr_regions.count), ptr_regions.baseAddress)
        }
    }

    public func cmdUpdateBuffer(dstBuffer: Buffer, dstOffset: VkDeviceSize, dataSize: VkDeviceSize, data: UnsafeRawPointer) -> Void {
        self.commandPool.device.dispatchTable.vkCmdUpdateBuffer(self.handle, dstBuffer.handle, dstOffset, dataSize, data)
    }

    public func cmdFillBuffer(dstBuffer: Buffer, dstOffset: VkDeviceSize, size: VkDeviceSize, data: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdFillBuffer(self.handle, dstBuffer.handle, dstOffset, size, data)
    }

    public func cmdClearColorImage(image: Image, imageLayout: ImageLayout, color: UnsafePointer<VkClearColorValue>, ranges: Array<ImageSubresourceRange>) -> Void {
        ranges.withCStructBufferPointer { ptr_ranges in
            self.commandPool.device.dispatchTable.vkCmdClearColorImage(self.handle, image.handle, VkImageLayout(rawValue: imageLayout.rawValue), color, UInt32(ptr_ranges.count), ptr_ranges.baseAddress)
        }
    }

    public func cmdClearDepthStencilImage(image: Image, imageLayout: ImageLayout, depthStencil: ClearDepthStencilValue, ranges: Array<ImageSubresourceRange>) -> Void {
        depthStencil.withCStruct { ptr_depthStencil in
            ranges.withCStructBufferPointer { ptr_ranges in
                self.commandPool.device.dispatchTable.vkCmdClearDepthStencilImage(self.handle, image.handle, VkImageLayout(rawValue: imageLayout.rawValue), ptr_depthStencil, UInt32(ptr_ranges.count), ptr_ranges.baseAddress)
            }
        }
    }

    public func cmdClearAttachments(attachments: Array<ClearAttachment>, rects: Array<ClearRect>) -> Void {
        attachments.withCStructBufferPointer { ptr_attachments in
            rects.withCStructBufferPointer { ptr_rects in
                self.commandPool.device.dispatchTable.vkCmdClearAttachments(self.handle, UInt32(ptr_attachments.count), ptr_attachments.baseAddress, UInt32(ptr_rects.count), ptr_rects.baseAddress)
            }
        }
    }

    public func cmdResolveImage(srcImage: Image, srcImageLayout: ImageLayout, dstImage: Image, dstImageLayout: ImageLayout, regions: Array<ImageResolve>) -> Void {
        regions.withCStructBufferPointer { ptr_regions in
            self.commandPool.device.dispatchTable.vkCmdResolveImage(self.handle, srcImage.handle, VkImageLayout(rawValue: srcImageLayout.rawValue), dstImage.handle, VkImageLayout(rawValue: dstImageLayout.rawValue), UInt32(ptr_regions.count), ptr_regions.baseAddress)
        }
    }

    public func cmdSetEvent(event: Event, stageMask: PipelineStageFlags) -> Void {
        self.commandPool.device.dispatchTable.vkCmdSetEvent(self.handle, event.handle, stageMask.rawValue)
    }

    public func cmdResetEvent(event: Event, stageMask: PipelineStageFlags) -> Void {
        self.commandPool.device.dispatchTable.vkCmdResetEvent(self.handle, event.handle, stageMask.rawValue)
    }

    public func cmdWaitEvents(events: Array<Event>, srcStageMask: PipelineStageFlags, dstStageMask: PipelineStageFlags, memoryBarriers: Array<MemoryBarrier>, bufferMemoryBarriers: Array<BufferMemoryBarrier>, imageMemoryBarriers: Array<ImageMemoryBarrier>) -> Void {
        events.map{ $0.handle }.withUnsafeBufferPointer { ptr_events in
            memoryBarriers.withCStructBufferPointer { ptr_memoryBarriers in
                bufferMemoryBarriers.withCStructBufferPointer { ptr_bufferMemoryBarriers in
                    imageMemoryBarriers.withCStructBufferPointer { ptr_imageMemoryBarriers in
                        self.commandPool.device.dispatchTable.vkCmdWaitEvents(self.handle, UInt32(ptr_events.count), ptr_events.baseAddress, srcStageMask.rawValue, dstStageMask.rawValue, UInt32(ptr_memoryBarriers.count), ptr_memoryBarriers.baseAddress, UInt32(ptr_bufferMemoryBarriers.count), ptr_bufferMemoryBarriers.baseAddress, UInt32(ptr_imageMemoryBarriers.count), ptr_imageMemoryBarriers.baseAddress)
                    }
                }
            }
        }
    }

    public func cmdPipelineBarrier(srcStageMask: PipelineStageFlags, dstStageMask: PipelineStageFlags, dependencyFlags: DependencyFlags, memoryBarriers: Array<MemoryBarrier>, bufferMemoryBarriers: Array<BufferMemoryBarrier>, imageMemoryBarriers: Array<ImageMemoryBarrier>) -> Void {
        memoryBarriers.withCStructBufferPointer { ptr_memoryBarriers in
            bufferMemoryBarriers.withCStructBufferPointer { ptr_bufferMemoryBarriers in
                imageMemoryBarriers.withCStructBufferPointer { ptr_imageMemoryBarriers in
                    self.commandPool.device.dispatchTable.vkCmdPipelineBarrier(self.handle, srcStageMask.rawValue, dstStageMask.rawValue, dependencyFlags.rawValue, UInt32(ptr_memoryBarriers.count), ptr_memoryBarriers.baseAddress, UInt32(ptr_bufferMemoryBarriers.count), ptr_bufferMemoryBarriers.baseAddress, UInt32(ptr_imageMemoryBarriers.count), ptr_imageMemoryBarriers.baseAddress)
                }
            }
        }
    }

    public func cmdBeginQuery(queryPool: QueryPool, query: UInt32, flags: QueryControlFlags) -> Void {
        self.commandPool.device.dispatchTable.vkCmdBeginQuery(self.handle, queryPool.handle, query, flags.rawValue)
    }

    public func cmdEndQuery(queryPool: QueryPool, query: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdEndQuery(self.handle, queryPool.handle, query)
    }

    public func cmdBeginConditionalRenderingEXT(conditionalRenderingBegin: ConditionalRenderingBeginInfoEXT) -> Void {
        conditionalRenderingBegin.withCStruct { ptr_conditionalRenderingBegin in
            self.commandPool.device.dispatchTable.vkCmdBeginConditionalRenderingEXT(self.handle, ptr_conditionalRenderingBegin)
        }
    }

    public func cmdEndConditionalRenderingEXT() -> Void {
        self.commandPool.device.dispatchTable.vkCmdEndConditionalRenderingEXT(self.handle)
    }

    public func cmdResetQueryPool(queryPool: QueryPool, firstQuery: UInt32, queryCount: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdResetQueryPool(self.handle, queryPool.handle, firstQuery, queryCount)
    }

    public func cmdWriteTimestamp(pipelineStage: PipelineStageFlags, queryPool: QueryPool, query: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdWriteTimestamp(self.handle, VkPipelineStageFlagBits(rawValue: pipelineStage.rawValue), queryPool.handle, query)
    }

    public func cmdCopyQueryPoolResults(queryPool: QueryPool, firstQuery: UInt32, queryCount: UInt32, dstBuffer: Buffer, dstOffset: VkDeviceSize, stride: VkDeviceSize, flags: QueryResultFlags) -> Void {
        self.commandPool.device.dispatchTable.vkCmdCopyQueryPoolResults(self.handle, queryPool.handle, firstQuery, queryCount, dstBuffer.handle, dstOffset, stride, flags.rawValue)
    }

    public func cmdPushConstants(layout: PipelineLayout, stageFlags: ShaderStageFlags, offset: UInt32, size: UInt32, values: UnsafeRawPointer) -> Void {
        self.commandPool.device.dispatchTable.vkCmdPushConstants(self.handle, layout.handle, stageFlags.rawValue, offset, size, values)
    }

    public func cmdBeginRenderPass(renderPassBegin: RenderPassBeginInfo, contents: SubpassContents) -> Void {
        renderPassBegin.withCStruct { ptr_renderPassBegin in
            self.commandPool.device.dispatchTable.vkCmdBeginRenderPass(self.handle, ptr_renderPassBegin, VkSubpassContents(rawValue: contents.rawValue))
        }
    }

    public func cmdNextSubpass(contents: SubpassContents) -> Void {
        self.commandPool.device.dispatchTable.vkCmdNextSubpass(self.handle, VkSubpassContents(rawValue: contents.rawValue))
    }

    public func cmdEndRenderPass() -> Void {
        self.commandPool.device.dispatchTable.vkCmdEndRenderPass(self.handle)
    }

    public func cmdExecuteCommands(commandBuffers: Array<CommandBuffer>) -> Void {
        commandBuffers.map{ $0.handle }.withUnsafeBufferPointer { ptr_commandBuffers in
            self.commandPool.device.dispatchTable.vkCmdExecuteCommands(self.handle, UInt32(ptr_commandBuffers.count), ptr_commandBuffers.baseAddress)
        }
    }

    public func cmdDebugMarkerBeginEXT(markerInfo: DebugMarkerMarkerInfoEXT) -> Void {
        markerInfo.withCStruct { ptr_markerInfo in
            self.commandPool.device.dispatchTable.vkCmdDebugMarkerBeginEXT(self.handle, ptr_markerInfo)
        }
    }

    public func cmdDebugMarkerEndEXT() -> Void {
        self.commandPool.device.dispatchTable.vkCmdDebugMarkerEndEXT(self.handle)
    }

    public func cmdDebugMarkerInsertEXT(markerInfo: DebugMarkerMarkerInfoEXT) -> Void {
        markerInfo.withCStruct { ptr_markerInfo in
            self.commandPool.device.dispatchTable.vkCmdDebugMarkerInsertEXT(self.handle, ptr_markerInfo)
        }
    }

    public func cmdExecuteGeneratedCommandsNV(isPreprocessed: Bool, generatedCommandsInfo: GeneratedCommandsInfoNV) -> Void {
        generatedCommandsInfo.withCStruct { ptr_generatedCommandsInfo in
            self.commandPool.device.dispatchTable.vkCmdExecuteGeneratedCommandsNV(self.handle, VkBool32(isPreprocessed ? VK_TRUE : VK_FALSE), ptr_generatedCommandsInfo)
        }
    }

    public func cmdPreprocessGeneratedCommandsNV(generatedCommandsInfo: GeneratedCommandsInfoNV) -> Void {
        generatedCommandsInfo.withCStruct { ptr_generatedCommandsInfo in
            self.commandPool.device.dispatchTable.vkCmdPreprocessGeneratedCommandsNV(self.handle, ptr_generatedCommandsInfo)
        }
    }

    public func cmdBindPipelineShaderGroupNV(pipelineBindPoint: PipelineBindPoint, pipeline: Pipeline, groupIndex: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdBindPipelineShaderGroupNV(self.handle, VkPipelineBindPoint(rawValue: pipelineBindPoint.rawValue), pipeline.handle, groupIndex)
    }

    public func cmdPushDescriptorSetKHR(pipelineBindPoint: PipelineBindPoint, layout: PipelineLayout, set: UInt32, descriptorWrites: Array<WriteDescriptorSet>) -> Void {
        descriptorWrites.withCStructBufferPointer { ptr_descriptorWrites in
            self.commandPool.device.dispatchTable.vkCmdPushDescriptorSetKHR(self.handle, VkPipelineBindPoint(rawValue: pipelineBindPoint.rawValue), layout.handle, set, UInt32(ptr_descriptorWrites.count), ptr_descriptorWrites.baseAddress)
        }
    }

    public func cmdSetDeviceMask(deviceMask: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdSetDeviceMask(self.handle, deviceMask)
    }

    public func cmdDispatchBase(baseGroupX: UInt32, baseGroupY: UInt32, baseGroupZ: UInt32, groupCountX: UInt32, groupCountY: UInt32, groupCountZ: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdDispatchBase(self.handle, baseGroupX, baseGroupY, baseGroupZ, groupCountX, groupCountY, groupCountZ)
    }

    public func cmdPushDescriptorSetWithTemplateKHR(descriptorUpdateTemplate: DescriptorUpdateTemplate, layout: PipelineLayout, set: UInt32, data: UnsafeRawPointer) -> Void {
        self.commandPool.device.dispatchTable.vkCmdPushDescriptorSetWithTemplateKHR(self.handle, descriptorUpdateTemplate.handle, layout.handle, set, data)
    }

    public func cmdSetViewportWScalingNV(firstViewport: UInt32, viewportWScalings: Array<ViewportWScalingNV>) -> Void {
        viewportWScalings.withCStructBufferPointer { ptr_viewportWScalings in
            self.commandPool.device.dispatchTable.vkCmdSetViewportWScalingNV(self.handle, firstViewport, UInt32(ptr_viewportWScalings.count), ptr_viewportWScalings.baseAddress)
        }
    }

    public func cmdSetDiscardRectangleEXT(firstDiscardRectangle: UInt32, discardRectangles: Array<Rect2D>) -> Void {
        discardRectangles.withCStructBufferPointer { ptr_discardRectangles in
            self.commandPool.device.dispatchTable.vkCmdSetDiscardRectangleEXT(self.handle, firstDiscardRectangle, UInt32(ptr_discardRectangles.count), ptr_discardRectangles.baseAddress)
        }
    }

    public func cmdSetSampleLocationsEXT(sampleLocationsInfo: SampleLocationsInfoEXT) -> Void {
        sampleLocationsInfo.withCStruct { ptr_sampleLocationsInfo in
            self.commandPool.device.dispatchTable.vkCmdSetSampleLocationsEXT(self.handle, ptr_sampleLocationsInfo)
        }
    }

    public func cmdBeginDebugUtilsLabelEXT(labelInfo: DebugUtilsLabelEXT) -> Void {
        labelInfo.withCStruct { ptr_labelInfo in
            self.commandPool.device.dispatchTable.vkCmdBeginDebugUtilsLabelEXT(self.handle, ptr_labelInfo)
        }
    }

    public func cmdEndDebugUtilsLabelEXT() -> Void {
        self.commandPool.device.dispatchTable.vkCmdEndDebugUtilsLabelEXT(self.handle)
    }

    public func cmdInsertDebugUtilsLabelEXT(labelInfo: DebugUtilsLabelEXT) -> Void {
        labelInfo.withCStruct { ptr_labelInfo in
            self.commandPool.device.dispatchTable.vkCmdInsertDebugUtilsLabelEXT(self.handle, ptr_labelInfo)
        }
    }

    public func cmdWriteBufferMarkerAMD(pipelineStage: PipelineStageFlags, dstBuffer: Buffer, dstOffset: VkDeviceSize, marker: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdWriteBufferMarkerAMD(self.handle, VkPipelineStageFlagBits(rawValue: pipelineStage.rawValue), dstBuffer.handle, dstOffset, marker)
    }

    public func cmdBeginRenderPass2(renderPassBegin: RenderPassBeginInfo, subpassBeginInfo: SubpassBeginInfo) -> Void {
        renderPassBegin.withCStruct { ptr_renderPassBegin in
            subpassBeginInfo.withCStruct { ptr_subpassBeginInfo in
                self.commandPool.device.dispatchTable.vkCmdBeginRenderPass2(self.handle, ptr_renderPassBegin, ptr_subpassBeginInfo)
            }
        }
    }

    public func cmdNextSubpass2(subpassBeginInfo: SubpassBeginInfo, subpassEndInfo: SubpassEndInfo) -> Void {
        subpassBeginInfo.withCStruct { ptr_subpassBeginInfo in
            subpassEndInfo.withCStruct { ptr_subpassEndInfo in
                self.commandPool.device.dispatchTable.vkCmdNextSubpass2(self.handle, ptr_subpassBeginInfo, ptr_subpassEndInfo)
            }
        }
    }

    public func cmdEndRenderPass2(subpassEndInfo: SubpassEndInfo) -> Void {
        subpassEndInfo.withCStruct { ptr_subpassEndInfo in
            self.commandPool.device.dispatchTable.vkCmdEndRenderPass2(self.handle, ptr_subpassEndInfo)
        }
    }

    public func cmdDrawIndirectCount(buffer: Buffer, offset: VkDeviceSize, countBuffer: Buffer, countBufferOffset: VkDeviceSize, maxDrawCount: UInt32, stride: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdDrawIndirectCount(self.handle, buffer.handle, offset, countBuffer.handle, countBufferOffset, maxDrawCount, stride)
    }

    public func cmdDrawIndexedIndirectCount(buffer: Buffer, offset: VkDeviceSize, countBuffer: Buffer, countBufferOffset: VkDeviceSize, maxDrawCount: UInt32, stride: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdDrawIndexedIndirectCount(self.handle, buffer.handle, offset, countBuffer.handle, countBufferOffset, maxDrawCount, stride)
    }

    public func cmdSetCheckpointNV(checkpointMarker: UnsafeRawPointer) -> Void {
        self.commandPool.device.dispatchTable.vkCmdSetCheckpointNV(self.handle, checkpointMarker)
    }

    public func cmdBindTransformFeedbackBuffersEXT(firstBinding: UInt32, buffers: Array<Buffer>, offsets: Array<VkDeviceSize>, sizes: Array<VkDeviceSize>?) -> Void {
        buffers.map{ $0.handle }.withUnsafeBufferPointer { ptr_buffers in
            offsets.withUnsafeBufferPointer { ptr_offsets in
                sizes.withOptionalUnsafeBufferPointer { ptr_sizes in
                    self.commandPool.device.dispatchTable.vkCmdBindTransformFeedbackBuffersEXT(self.handle, firstBinding, UInt32(ptr_buffers.count), ptr_buffers.baseAddress, ptr_offsets.baseAddress, ptr_sizes.baseAddress)
                }
            }
        }
    }

    public func cmdBeginTransformFeedbackEXT(firstCounterBuffer: UInt32, counterBuffers: Array<Buffer>, counterBufferOffsets: Array<VkDeviceSize>?) -> Void {
        counterBuffers.map{ $0.handle }.withUnsafeBufferPointer { ptr_counterBuffers in
            counterBufferOffsets.withOptionalUnsafeBufferPointer { ptr_counterBufferOffsets in
                self.commandPool.device.dispatchTable.vkCmdBeginTransformFeedbackEXT(self.handle, firstCounterBuffer, UInt32(ptr_counterBuffers.count), ptr_counterBuffers.baseAddress, ptr_counterBufferOffsets.baseAddress)
            }
        }
    }

    public func cmdEndTransformFeedbackEXT(firstCounterBuffer: UInt32, counterBuffers: Array<Buffer>, counterBufferOffsets: Array<VkDeviceSize>?) -> Void {
        counterBuffers.map{ $0.handle }.withUnsafeBufferPointer { ptr_counterBuffers in
            counterBufferOffsets.withOptionalUnsafeBufferPointer { ptr_counterBufferOffsets in
                self.commandPool.device.dispatchTable.vkCmdEndTransformFeedbackEXT(self.handle, firstCounterBuffer, UInt32(ptr_counterBuffers.count), ptr_counterBuffers.baseAddress, ptr_counterBufferOffsets.baseAddress)
            }
        }
    }

    public func cmdBeginQueryIndexedEXT(queryPool: QueryPool, query: UInt32, flags: QueryControlFlags, index: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdBeginQueryIndexedEXT(self.handle, queryPool.handle, query, flags.rawValue, index)
    }

    public func cmdEndQueryIndexedEXT(queryPool: QueryPool, query: UInt32, index: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdEndQueryIndexedEXT(self.handle, queryPool.handle, query, index)
    }

    public func cmdDrawIndirectByteCountEXT(instanceCount: UInt32, firstInstance: UInt32, counterBuffer: Buffer, counterBufferOffset: VkDeviceSize, counterOffset: UInt32, vertexStride: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdDrawIndirectByteCountEXT(self.handle, instanceCount, firstInstance, counterBuffer.handle, counterBufferOffset, counterOffset, vertexStride)
    }

    public func cmdSetExclusiveScissorNV(firstExclusiveScissor: UInt32, exclusiveScissors: Array<Rect2D>) -> Void {
        exclusiveScissors.withCStructBufferPointer { ptr_exclusiveScissors in
            self.commandPool.device.dispatchTable.vkCmdSetExclusiveScissorNV(self.handle, firstExclusiveScissor, UInt32(ptr_exclusiveScissors.count), ptr_exclusiveScissors.baseAddress)
        }
    }

    public func cmdBindShadingRateImageNV(imageView: ImageView?, imageLayout: ImageLayout) -> Void {
        self.commandPool.device.dispatchTable.vkCmdBindShadingRateImageNV(self.handle, imageView?.handle, VkImageLayout(rawValue: imageLayout.rawValue))
    }

    public func cmdSetViewportShadingRatePaletteNV(firstViewport: UInt32, shadingRatePalettes: Array<ShadingRatePaletteNV>) -> Void {
        shadingRatePalettes.withCStructBufferPointer { ptr_shadingRatePalettes in
            self.commandPool.device.dispatchTable.vkCmdSetViewportShadingRatePaletteNV(self.handle, firstViewport, UInt32(ptr_shadingRatePalettes.count), ptr_shadingRatePalettes.baseAddress)
        }
    }

    public func cmdSetCoarseSampleOrderNV(sampleOrderType: CoarseSampleOrderTypeNV, customSampleOrders: Array<CoarseSampleOrderCustomNV>) -> Void {
        customSampleOrders.withCStructBufferPointer { ptr_customSampleOrders in
            self.commandPool.device.dispatchTable.vkCmdSetCoarseSampleOrderNV(self.handle, VkCoarseSampleOrderTypeNV(rawValue: sampleOrderType.rawValue), UInt32(ptr_customSampleOrders.count), ptr_customSampleOrders.baseAddress)
        }
    }

    public func cmdDrawMeshTasksNV(taskCount: UInt32, firstTask: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdDrawMeshTasksNV(self.handle, taskCount, firstTask)
    }

    public func cmdDrawMeshTasksIndirectNV(buffer: Buffer, offset: VkDeviceSize, drawCount: UInt32, stride: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdDrawMeshTasksIndirectNV(self.handle, buffer.handle, offset, drawCount, stride)
    }

    public func cmdDrawMeshTasksIndirectCountNV(buffer: Buffer, offset: VkDeviceSize, countBuffer: Buffer, countBufferOffset: VkDeviceSize, maxDrawCount: UInt32, stride: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdDrawMeshTasksIndirectCountNV(self.handle, buffer.handle, offset, countBuffer.handle, countBufferOffset, maxDrawCount, stride)
    }

    public func cmdCopyAccelerationStructureNV(dst: AccelerationStructureKHR, src: AccelerationStructureKHR, mode: VkCopyAccelerationStructureModeKHR) -> Void {
        self.commandPool.device.dispatchTable.vkCmdCopyAccelerationStructureNV(self.handle, dst.handle, src.handle, mode)
    }

    public func cmdBuildAccelerationStructureNV(info: AccelerationStructureInfoNV, instanceData: Buffer?, instanceOffset: VkDeviceSize, update: Bool, dst: AccelerationStructureKHR, src: AccelerationStructureKHR?, scratch: Buffer, scratchOffset: VkDeviceSize) -> Void {
        info.withCStruct { ptr_info in
            self.commandPool.device.dispatchTable.vkCmdBuildAccelerationStructureNV(self.handle, ptr_info, instanceData?.handle, instanceOffset, VkBool32(update ? VK_TRUE : VK_FALSE), dst.handle, src?.handle, scratch.handle, scratchOffset)
        }
    }

    public func cmdTraceRaysNV(raygenShaderBindingTableBuffer: Buffer, raygenShaderBindingOffset: VkDeviceSize, missShaderBindingTableBuffer: Buffer?, missShaderBindingOffset: VkDeviceSize, missShaderBindingStride: VkDeviceSize, hitShaderBindingTableBuffer: Buffer?, hitShaderBindingOffset: VkDeviceSize, hitShaderBindingStride: VkDeviceSize, callableShaderBindingTableBuffer: Buffer?, callableShaderBindingOffset: VkDeviceSize, callableShaderBindingStride: VkDeviceSize, width: UInt32, height: UInt32, depth: UInt32) -> Void {
        self.commandPool.device.dispatchTable.vkCmdTraceRaysNV(self.handle, raygenShaderBindingTableBuffer.handle, raygenShaderBindingOffset, missShaderBindingTableBuffer?.handle, missShaderBindingOffset, missShaderBindingStride, hitShaderBindingTableBuffer?.handle, hitShaderBindingOffset, hitShaderBindingStride, callableShaderBindingTableBuffer?.handle, callableShaderBindingOffset, callableShaderBindingStride, width, height, depth)
    }

    public func cmdSetPerformanceMarkerINTEL(markerInfo: PerformanceMarkerInfoINTEL) throws -> Void {
        try markerInfo.withCStruct { ptr_markerInfo in
            try checkResult(
                self.commandPool.device.dispatchTable.vkCmdSetPerformanceMarkerINTEL(self.handle, ptr_markerInfo)
            )
        }
    }

    public func cmdSetPerformanceStreamMarkerINTEL(markerInfo: PerformanceStreamMarkerInfoINTEL) throws -> Void {
        try markerInfo.withCStruct { ptr_markerInfo in
            try checkResult(
                self.commandPool.device.dispatchTable.vkCmdSetPerformanceStreamMarkerINTEL(self.handle, ptr_markerInfo)
            )
        }
    }

    public func cmdSetPerformanceOverrideINTEL(overrideInfo: PerformanceOverrideInfoINTEL) throws -> Void {
        try overrideInfo.withCStruct { ptr_overrideInfo in
            try checkResult(
                self.commandPool.device.dispatchTable.vkCmdSetPerformanceOverrideINTEL(self.handle, ptr_overrideInfo)
            )
        }
    }

    public func cmdSetLineStippleEXT(lineStippleFactor: UInt32, lineStipplePattern: UInt16) -> Void {
        self.commandPool.device.dispatchTable.vkCmdSetLineStippleEXT(self.handle, lineStippleFactor, lineStipplePattern)
    }
}

public class DeviceMemory: _HandleContainer {
    let handle: VkDeviceMemory?
    public let device: Device

    public init(handle: VkDeviceMemory!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func freeMemory() -> Void {
        self.device.dispatchTable.vkFreeMemory(self.device.handle, self.handle, nil)
    }

    public func mapMemory(offset: VkDeviceSize, size: VkDeviceSize, flags: MemoryMapFlags) throws -> UnsafeMutableRawPointer {
        var out: UnsafeMutableRawPointer!
        try checkResult(
            self.device.dispatchTable.vkMapMemory(self.device.handle, self.handle, offset, size, flags.rawValue, &out)
        )
        return out
    }

    public func unmapMemory() -> Void {
        self.device.dispatchTable.vkUnmapMemory(self.device.handle, self.handle)
    }

    public func getCommitment() -> VkDeviceSize {
        var out = VkDeviceSize()
        self.device.dispatchTable.vkGetDeviceMemoryCommitment(self.device.handle, self.handle, &out)
        return out
    }
}

public class Buffer: _HandleContainer {
    let handle: VkBuffer?
    public let device: Device

    public init(handle: VkBuffer!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func getMemoryRequirements() -> MemoryRequirements {
        var out = VkMemoryRequirements()
        self.device.dispatchTable.vkGetBufferMemoryRequirements(self.device.handle, self.handle, &out)
        return MemoryRequirements(cStruct: out)
    }

    public func bindMemory(memory: DeviceMemory, memoryOffset: VkDeviceSize) throws -> Void {
        try checkResult(
            self.device.dispatchTable.vkBindBufferMemory(self.device.handle, self.handle, memory.handle, memoryOffset)
        )
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroyBuffer(self.device.handle, self.handle, nil)
    }
}

public class BufferView: _HandleContainer {
    let handle: VkBufferView?
    public let device: Device

    public init(handle: VkBufferView!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroyBufferView(self.device.handle, self.handle, nil)
    }
}

public class Image: _HandleContainer {
    let handle: VkImage?
    public let device: Device

    public init(handle: VkImage!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func getMemoryRequirements() -> MemoryRequirements {
        var out = VkMemoryRequirements()
        self.device.dispatchTable.vkGetImageMemoryRequirements(self.device.handle, self.handle, &out)
        return MemoryRequirements(cStruct: out)
    }

    public func bindMemory(memory: DeviceMemory, memoryOffset: VkDeviceSize) throws -> Void {
        try checkResult(
            self.device.dispatchTable.vkBindImageMemory(self.device.handle, self.handle, memory.handle, memoryOffset)
        )
    }

    public func getSparseMemoryRequirements() -> Array<SparseImageMemoryRequirements> {
        enumerate { pSparseMemoryRequirements, pSparseMemoryRequirementCount in
            self.device.dispatchTable.vkGetImageSparseMemoryRequirements(self.device.handle, self.handle, pSparseMemoryRequirementCount, pSparseMemoryRequirements)
        }.map { SparseImageMemoryRequirements(cStruct: $0) }
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroyImage(self.device.handle, self.handle, nil)
    }

    public func getSubresourceLayout(subresource: ImageSubresource) -> SubresourceLayout {
        subresource.withCStruct { ptr_subresource in
            var out = VkSubresourceLayout()
            self.device.dispatchTable.vkGetImageSubresourceLayout(self.device.handle, self.handle, ptr_subresource, &out)
            return SubresourceLayout(cStruct: out)
        }
    }

    public func getDrmFormatModifierPropertiesEXT() throws -> ImageDrmFormatModifierPropertiesEXT {
        var out = VkImageDrmFormatModifierPropertiesEXT()
        try checkResult(
            self.device.dispatchTable.vkGetImageDrmFormatModifierPropertiesEXT(self.device.handle, self.handle, &out)
        )
        return ImageDrmFormatModifierPropertiesEXT(cStruct: out)
    }
}

public class ImageView: _HandleContainer {
    let handle: VkImageView?
    public let device: Device

    public init(handle: VkImageView!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroyImageView(self.device.handle, self.handle, nil)
    }
}

public class ShaderModule: _HandleContainer {
    let handle: VkShaderModule?
    public let device: Device

    public init(handle: VkShaderModule!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroyShaderModule(self.device.handle, self.handle, nil)
    }
}

public class Pipeline: _HandleContainer {
    let handle: VkPipeline?
    public let device: Device

    public init(handle: VkPipeline!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroyPipeline(self.device.handle, self.handle, nil)
    }

    public func getShaderInfoAMD(shaderStage: ShaderStageFlags, infoType: ShaderInfoTypeAMD, info: UnsafeMutableRawPointer?) throws -> Int {
        var out = Int()
        try checkResult(
            self.device.dispatchTable.vkGetShaderInfoAMD(self.device.handle, self.handle, VkShaderStageFlagBits(rawValue: shaderStage.rawValue), VkShaderInfoTypeAMD(rawValue: infoType.rawValue), &out, info)
        )
        return out
    }

    public func compileDeferredNV(shader: UInt32) throws -> Void {
        try checkResult(
            self.device.dispatchTable.vkCompileDeferredNV(self.device.handle, self.handle, shader)
        )
    }
}

public class PipelineLayout: _HandleContainer {
    let handle: VkPipelineLayout?
    public let device: Device

    public init(handle: VkPipelineLayout!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroyPipelineLayout(self.device.handle, self.handle, nil)
    }
}

public class Sampler: _HandleContainer {
    let handle: VkSampler?
    public let device: Device

    public init(handle: VkSampler!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroySampler(self.device.handle, self.handle, nil)
    }
}

public class DescriptorPool: _HandleContainer {
    let handle: VkDescriptorPool?
    public let device: Device

    public init(handle: VkDescriptorPool!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroyDescriptorPool(self.device.handle, self.handle, nil)
    }

    public func reset(flags: DescriptorPoolResetFlags) throws -> Void {
        try checkResult(
            self.device.dispatchTable.vkResetDescriptorPool(self.device.handle, self.handle, flags.rawValue)
        )
    }

    public func freeDescriptorSets(descriptorSets: Array<DescriptorSet>) throws -> Void {
        try descriptorSets.map{ $0.handle }.withUnsafeBufferPointer { ptr_descriptorSets in
            try checkResult(
                self.device.dispatchTable.vkFreeDescriptorSets(self.device.handle, self.handle, UInt32(ptr_descriptorSets.count), ptr_descriptorSets.baseAddress)
            )
        }
    }
}

public class DescriptorSet: _HandleContainer {
    let handle: VkDescriptorSet?
    public let descriptorPool: DescriptorPool

    public init(handle: VkDescriptorSet!, descriptorPool: DescriptorPool) {
        self.handle = handle
        self.descriptorPool = descriptorPool
    }

    public func updateWithTemplate(descriptorUpdateTemplate: DescriptorUpdateTemplate, data: UnsafeRawPointer) -> Void {
        self.descriptorPool.device.dispatchTable.vkUpdateDescriptorSetWithTemplate(self.descriptorPool.device.handle, self.handle, descriptorUpdateTemplate.handle, data)
    }
}

public class DescriptorSetLayout: _HandleContainer {
    let handle: VkDescriptorSetLayout?
    public let device: Device

    public init(handle: VkDescriptorSetLayout!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroyDescriptorSetLayout(self.device.handle, self.handle, nil)
    }
}

public class Fence: _HandleContainer {
    let handle: VkFence?
    public let device: Device

    public init(handle: VkFence!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroyFence(self.device.handle, self.handle, nil)
    }

    public func getStatus() throws -> Void {
        try checkResult(
            self.device.dispatchTable.vkGetFenceStatus(self.device.handle, self.handle)
        )
    }
}

public class Semaphore: _HandleContainer {
    let handle: VkSemaphore?
    public let device: Device

    public init(handle: VkSemaphore!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroySemaphore(self.device.handle, self.handle, nil)
    }

    public func getCounterValue() throws -> UInt64 {
        var out = UInt64()
        try checkResult(
            self.device.dispatchTable.vkGetSemaphoreCounterValue(self.device.handle, self.handle, &out)
        )
        return out
    }
}

public class Event: _HandleContainer {
    let handle: VkEvent?
    public let device: Device

    public init(handle: VkEvent!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroyEvent(self.device.handle, self.handle, nil)
    }

    public func getStatus() throws -> Void {
        try checkResult(
            self.device.dispatchTable.vkGetEventStatus(self.device.handle, self.handle)
        )
    }

    public func set() throws -> Void {
        try checkResult(
            self.device.dispatchTable.vkSetEvent(self.device.handle, self.handle)
        )
    }

    public func reset() throws -> Void {
        try checkResult(
            self.device.dispatchTable.vkResetEvent(self.device.handle, self.handle)
        )
    }
}

public class QueryPool: _HandleContainer {
    let handle: VkQueryPool?
    public let device: Device

    public init(handle: VkQueryPool!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroyQueryPool(self.device.handle, self.handle, nil)
    }

    public func getResults(firstQuery: UInt32, queryCount: UInt32, dataSize: Int, data: UnsafeMutableRawPointer, stride: VkDeviceSize, flags: QueryResultFlags) throws -> Void {
        try checkResult(
            self.device.dispatchTable.vkGetQueryPoolResults(self.device.handle, self.handle, firstQuery, queryCount, dataSize, data, stride, flags.rawValue)
        )
    }

    public func reset(firstQuery: UInt32, queryCount: UInt32) -> Void {
        self.device.dispatchTable.vkResetQueryPool(self.device.handle, self.handle, firstQuery, queryCount)
    }
}

public class Framebuffer: _HandleContainer {
    let handle: VkFramebuffer?
    public let device: Device

    public init(handle: VkFramebuffer!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroyFramebuffer(self.device.handle, self.handle, nil)
    }
}

public class RenderPass: _HandleContainer {
    let handle: VkRenderPass?
    public let device: Device

    public init(handle: VkRenderPass!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroyRenderPass(self.device.handle, self.handle, nil)
    }

    public func getRenderAreaGranularity() -> Extent2D {
        var out = VkExtent2D()
        self.device.dispatchTable.vkGetRenderAreaGranularity(self.device.handle, self.handle, &out)
        return Extent2D(cStruct: out)
    }
}

public class PipelineCache: _HandleContainer {
    let handle: VkPipelineCache?
    public let device: Device

    public init(handle: VkPipelineCache!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroyPipelineCache(self.device.handle, self.handle, nil)
    }

    public func getData(data: UnsafeMutableRawPointer?) throws -> Int {
        var out = Int()
        try checkResult(
            self.device.dispatchTable.vkGetPipelineCacheData(self.device.handle, self.handle, &out, data)
        )
        return out
    }

    public func mergePipelineCaches(srcCaches: Array<PipelineCache>) throws -> Void {
        try srcCaches.map{ $0.handle }.withUnsafeBufferPointer { ptr_srcCaches in
            try checkResult(
                self.device.dispatchTable.vkMergePipelineCaches(self.device.handle, self.handle, UInt32(ptr_srcCaches.count), ptr_srcCaches.baseAddress)
            )
        }
    }
}

public class IndirectCommandsLayoutNV: _HandleContainer {
    let handle: VkIndirectCommandsLayoutNV?
    public let device: Device

    public init(handle: VkIndirectCommandsLayoutNV!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroyNV() -> Void {
        self.device.dispatchTable.vkDestroyIndirectCommandsLayoutNV(self.device.handle, self.handle, nil)
    }
}

public class DescriptorUpdateTemplate: _HandleContainer {
    let handle: VkDescriptorUpdateTemplate?
    public let device: Device

    public init(handle: VkDescriptorUpdateTemplate!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroyDescriptorUpdateTemplate(self.device.handle, self.handle, nil)
    }
}

public class SamplerYcbcrConversion: _HandleContainer {
    let handle: VkSamplerYcbcrConversion?
    public let device: Device

    public init(handle: VkSamplerYcbcrConversion!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroy() -> Void {
        self.device.dispatchTable.vkDestroySamplerYcbcrConversion(self.device.handle, self.handle, nil)
    }
}

public class ValidationCacheEXT: _HandleContainer {
    let handle: VkValidationCacheEXT?
    public let device: Device

    public init(handle: VkValidationCacheEXT!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroyEXT() -> Void {
        self.device.dispatchTable.vkDestroyValidationCacheEXT(self.device.handle, self.handle, nil)
    }

    public func getDataEXT(data: UnsafeMutableRawPointer?) throws -> Int {
        var out = Int()
        try checkResult(
            self.device.dispatchTable.vkGetValidationCacheDataEXT(self.device.handle, self.handle, &out, data)
        )
        return out
    }

    public func mergeValidationCachesEXT(srcCaches: Array<ValidationCacheEXT>) throws -> Void {
        try srcCaches.map{ $0.handle }.withUnsafeBufferPointer { ptr_srcCaches in
            try checkResult(
                self.device.dispatchTable.vkMergeValidationCachesEXT(self.device.handle, self.handle, UInt32(ptr_srcCaches.count), ptr_srcCaches.baseAddress)
            )
        }
    }
}

public class AccelerationStructureKHR: _HandleContainer {
    let handle: VkAccelerationStructureKHR?
    public let device: Device

    public init(handle: VkAccelerationStructureKHR!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func getHandleNV(dataSize: Int, data: UnsafeMutableRawPointer) throws -> Void {
        try checkResult(
            self.device.dispatchTable.vkGetAccelerationStructureHandleNV(self.device.handle, self.handle, dataSize, data)
        )
    }
}

public class PerformanceConfigurationINTEL: _HandleContainer {
    let handle: VkPerformanceConfigurationINTEL?
    public let device: Device

    public init(handle: VkPerformanceConfigurationINTEL!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func releaseINTEL() throws -> Void {
        try checkResult(
            self.device.dispatchTable.vkReleasePerformanceConfigurationINTEL(self.device.handle, self.handle)
        )
    }
}

public class DisplayKHR: _HandleContainer {
    let handle: VkDisplayKHR?
    public let physicalDevice: PhysicalDevice

    public init(handle: VkDisplayKHR!, physicalDevice: PhysicalDevice) {
        self.handle = handle
        self.physicalDevice = physicalDevice
    }

    public func getModePropertiesKHR() throws -> Array<DisplayModePropertiesKHR> {
        try enumerate { pProperties, pPropertyCount in
            self.physicalDevice.instance.dispatchTable.vkGetDisplayModePropertiesKHR(self.physicalDevice.handle, self.handle, pPropertyCount, pProperties)
        }.map { DisplayModePropertiesKHR(cStruct: $0, display: self) }
    }

    public func createModeKHR(createInfo: DisplayModeCreateInfoKHR) throws -> DisplayModeKHR {
        try createInfo.withCStruct { ptr_createInfo in
            var out: VkDisplayModeKHR!
            try checkResult(
                self.physicalDevice.instance.dispatchTable.vkCreateDisplayModeKHR(self.physicalDevice.handle, self.handle, ptr_createInfo, nil, &out)
            )
            return DisplayModeKHR(handle: out, display: self)
        }
    }

    public func releaseEXT() throws -> Void {
        try checkResult(
            self.physicalDevice.instance.dispatchTable.vkReleaseDisplayEXT(self.physicalDevice.handle, self.handle)
        )
    }

    public func getModeProperties2KHR() throws -> Array<DisplayModeProperties2KHR> {
        try enumerate { pProperties, pPropertyCount in
            self.physicalDevice.instance.dispatchTable.vkGetDisplayModeProperties2KHR(self.physicalDevice.handle, self.handle, pPropertyCount, pProperties)
        }.map { DisplayModeProperties2KHR(cStruct: $0, display: self) }
    }
}

public class DisplayModeKHR: _HandleContainer {
    let handle: VkDisplayModeKHR?
    public let display: DisplayKHR

    public init(handle: VkDisplayModeKHR!, display: DisplayKHR) {
        self.handle = handle
        self.display = display
    }

    public func getDisplayPlaneCapabilitiesKHR(planeIndex: UInt32) throws -> DisplayPlaneCapabilitiesKHR {
        var out = VkDisplayPlaneCapabilitiesKHR()
        try checkResult(
            self.display.physicalDevice.instance.dispatchTable.vkGetDisplayPlaneCapabilitiesKHR(self.display.physicalDevice.handle, self.handle, planeIndex, &out)
        )
        return DisplayPlaneCapabilitiesKHR(cStruct: out)
    }
}

public class SurfaceKHR: _HandleContainer {
    let handle: VkSurfaceKHR?
    public let instance: Instance

    public init(handle: VkSurfaceKHR!, instance: Instance) {
        self.handle = handle
        self.instance = instance
    }

    public func destroyKHR() -> Void {
        self.instance.dispatchTable.vkDestroySurfaceKHR(self.instance.handle, self.handle, nil)
    }
}

public class SwapchainKHR: _HandleContainer {
    let handle: VkSwapchainKHR?
    public let device: Device

    public init(handle: VkSwapchainKHR!, device: Device) {
        self.handle = handle
        self.device = device
    }

    public func destroyKHR() -> Void {
        self.device.dispatchTable.vkDestroySwapchainKHR(self.device.handle, self.handle, nil)
    }

    public func getImagesKHR() throws -> Array<Image> {
        try enumerate { pSwapchainImages, pSwapchainImageCount in
            self.device.dispatchTable.vkGetSwapchainImagesKHR(self.device.handle, self.handle, pSwapchainImageCount, pSwapchainImages)
        }.map { Image(handle: $0, device: self.device) }
    }

    public func acquireNextImageKHR(timeout: UInt64, semaphore: Semaphore?, fence: Fence?) throws -> UInt32 {
        var out = UInt32()
        try checkResult(
            self.device.dispatchTable.vkAcquireNextImageKHR(self.device.handle, self.handle, timeout, semaphore?.handle, fence?.handle, &out)
        )
        return out
    }

    public func getCounterEXT(counter: SurfaceCounterFlagsEXT) throws -> UInt64 {
        var out = UInt64()
        try checkResult(
            self.device.dispatchTable.vkGetSwapchainCounterEXT(self.device.handle, self.handle, VkSurfaceCounterFlagBitsEXT(rawValue: counter.rawValue), &out)
        )
        return out
    }

    public func getStatusKHR() throws -> Void {
        try checkResult(
            self.device.dispatchTable.vkGetSwapchainStatusKHR(self.device.handle, self.handle)
        )
    }

    public func getRefreshCycleDurationGOOGLE() throws -> RefreshCycleDurationGOOGLE {
        var out = VkRefreshCycleDurationGOOGLE()
        try checkResult(
            self.device.dispatchTable.vkGetRefreshCycleDurationGOOGLE(self.device.handle, self.handle, &out)
        )
        return RefreshCycleDurationGOOGLE(cStruct: out)
    }

    public func getPastPresentationTimingGOOGLE() throws -> Array<PastPresentationTimingGOOGLE> {
        try enumerate { pPresentationTimings, pPresentationTimingCount in
            self.device.dispatchTable.vkGetPastPresentationTimingGOOGLE(self.device.handle, self.handle, pPresentationTimingCount, pPresentationTimings)
        }.map { PastPresentationTimingGOOGLE(cStruct: $0) }
    }

    public func setLocalDimmingAMD(localDimmingEnable: Bool) -> Void {
        self.device.dispatchTable.vkSetLocalDimmingAMD(self.device.handle, self.handle, VkBool32(localDimmingEnable ? VK_TRUE : VK_FALSE))
    }
}

public class DebugReportCallbackEXT: _HandleContainer {
    let handle: VkDebugReportCallbackEXT?
    public let instance: Instance

    public init(handle: VkDebugReportCallbackEXT!, instance: Instance) {
        self.handle = handle
        self.instance = instance
    }

    public func destroyEXT() -> Void {
        self.instance.dispatchTable.vkDestroyDebugReportCallbackEXT(self.instance.handle, self.handle, nil)
    }
}

public class DebugUtilsMessengerEXT: _HandleContainer {
    let handle: VkDebugUtilsMessengerEXT?
    public let instance: Instance

    public init(handle: VkDebugUtilsMessengerEXT!, instance: Instance) {
        self.handle = handle
        self.instance = instance
    }

    public func destroyEXT() -> Void {
        self.instance.dispatchTable.vkDestroyDebugUtilsMessengerEXT(self.instance.handle, self.handle, nil)
    }
}

