local renderBluePortal = true

return function(bluePortal, redPortal, char, blueViewport, redViewport, blueViewportCamera, redViewportCamera)
    if shared.Settings.PortalRendering then
        local mainPortal = renderBluePortal and bluePortal.Portal or redPortal.Portal
        local otherPortal = renderBluePortal and redPortal.Portal or bluePortal.Portal
        local mainViewport = renderBluePortal and blueViewport or redViewport
        local mainCamera = renderBluePortal and blueViewportCamera or redViewportCamera

        if bluePortal.OnPart.Value and redPortal.OnPart.Value then
            mainViewport.Visible = true

            mainViewport:ClearAllChildren()

            local vpfMask = otherPortal.Parent.ViewportFrameMask:Clone()
            vpfMask.Parent = mainViewport
            vpfMask.Transparency = 0

            mainCamera.CFrame = mainPortal.CFrame

            local partsInVisibilityHitbox = workspace:GetPartsInPart(otherPortal.Parent.VisibilityHitbox)
            for _, part in partsInVisibilityHitbox do
                if part:IsDescendantOf(char) then continue end
                part:Clone().Parent = mainViewport
            end
        else
            mainViewport.Visible = false
        end

        renderBluePortal = not renderBluePortal
    end
end
