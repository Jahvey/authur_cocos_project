<GameFile>
  <PropertyGroup Name="chatView" Type="Node" ID="3996d73f-9e32-443c-932e-0d65cf11b329" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="0" Speed="1.0000" />
      <ObjectData Name="Node" Tag="28" ctype="GameNodeObjectData">
        <Size X="0.0000" Y="0.0000" />
        <Children>
          <AbstractNodeData Name="layer" ActionTag="-1043017125" Tag="29" IconVisible="False" LeftMargin="-637.6991" RightMargin="-642.3009" TopMargin="-361.7470" BottomMargin="-358.2530" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ComboBoxIndex="1" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
            <Size X="1280.0000" Y="720.0000" />
            <AnchorPoint />
            <Position X="-637.6991" Y="-358.2530" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="main" ActionTag="-66326621" Tag="30" IconVisible="True" LeftMargin="305.0000" RightMargin="-305.0000" TopMargin="26.0000" BottomMargin="-26.0000" ctype="SingleNodeObjectData">
            <Size X="0.0000" Y="0.0000" />
            <Children>
              <AbstractNodeData Name="bg" ActionTag="1400854048" Tag="31" IconVisible="False" LeftMargin="-261.7800" RightMargin="-326.2200" TopMargin="-320.6600" BottomMargin="-319.3400" TouchEnable="True" Scale9Enable="True" LeftEage="34" RightEage="34" TopEage="34" BottomEage="34" Scale9OriginX="34" Scale9OriginY="34" Scale9Width="36" Scale9Height="36" ctype="ImageViewObjectData">
                <Size X="588.0000" Y="640.0000" />
                <AnchorPoint />
                <Position X="-261.7800" Y="-319.3400" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="ui/chat/bg_orange.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="bg1" ActionTag="-1768221061" Tag="1077" IconVisible="False" LeftMargin="-247.1127" RightMargin="-240.8873" TopMargin="-304.7346" BottomMargin="-219.2654" TouchEnable="True" Scale9Enable="True" LeftEage="20" RightEage="20" TopEage="20" BottomEage="20" Scale9OriginX="20" Scale9OriginY="20" Scale9Width="23" Scale9Height="21" ctype="ImageViewObjectData">
                <Size X="488.0000" Y="524.0000" />
                <AnchorPoint />
                <Position X="-247.1127" Y="-219.2654" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="ui/chat/bg_yellow.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="scrollView" ActionTag="-1824604031" Tag="65" IconVisible="False" LeftMargin="-243.2731" RightMargin="-236.7269" TopMargin="-302.0423" BottomMargin="-215.9577" TouchEnable="True" ClipAble="True" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" IsBounceEnabled="True" ScrollDirectionType="Vertical" ctype="ScrollViewObjectData">
                <Size X="480.0000" Y="518.0000" />
                <AnchorPoint ScaleY="1.0000" />
                <Position X="-243.2731" Y="302.0423" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <SingleColor A="255" R="255" G="150" B="100" />
                <FirstColor A="255" R="255" G="150" B="100" />
                <EndColor A="255" R="255" G="255" B="255" />
                <ColorVector ScaleY="1.0000" />
                <InnerNodeSize Width="488" Height="518" />
              </AbstractNodeData>
              <AbstractNodeData Name="textFieldBg" ActionTag="1111471815" Tag="39" IconVisible="False" LeftMargin="-245.6523" RightMargin="-162.3477" TopMargin="233.3997" BottomMargin="-297.3997" Scale9Enable="True" LeftEage="17" RightEage="17" TopEage="13" BottomEage="13" Scale9OriginX="17" Scale9OriginY="13" Scale9Width="374" Scale9Height="38" ctype="ImageViewObjectData">
                <Size X="408.0000" Y="64.0000" />
                <Children>
                  <AbstractNodeData Name="textField" ActionTag="-1487352344" Tag="38" IconVisible="False" LeftMargin="13.2301" RightMargin="14.7699" TopMargin="20.9750" BottomMargin="17.0250" TouchEnable="True" FontSize="26" IsCustomSize="True" LabelText="你好啊" PlaceHolderText="" MaxLengthText="10" ctype="TextFieldObjectData">
                    <Size X="380.0000" Y="26.0000" />
                    <AnchorPoint ScaleY="0.5000" />
                    <Position X="13.2301" Y="30.0250" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="102" G="44" B="32" />
                    <PrePosition X="0.0324" Y="0.4691" />
                    <PreSize X="0.9314" Y="0.4063" />
                    <FontResource Type="Normal" Path="ui/common/DFYuanW7-GB2312.ttf" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="sendBtn" ActionTag="628499805" Tag="40" IconVisible="False" LeftMargin="415.3165" RightMargin="-149.3165" TopMargin="0.4757" BottomMargin="-3.4757" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="112" Scale9Height="45" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                    <Size X="142.0000" Y="67.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="486.3165" Y="30.0243" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="1.1920" Y="0.4691" />
                    <PreSize X="0.3480" Y="1.0469" />
                    <FontResource Type="Default" Path="" Plist="" />
                    <TextColor A="255" R="65" G="65" B="70" />
                    <DisabledFileData Type="Normal" Path="ui/chat/send_btn.png" Plist="" />
                    <PressedFileData Type="Normal" Path="ui/chat/send_btn.png" Plist="" />
                    <NormalFileData Type="Normal" Path="ui/chat/send_btn.png" Plist="" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="-41.6523" Y="-265.3997" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="ui/chat/text_area.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="listView" ActionTag="-622780626" Tag="41" IconVisible="False" LeftMargin="-243.2732" RightMargin="-236.7268" TopMargin="-302.0423" BottomMargin="-215.9577" TouchEnable="True" ClipAble="True" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" IsBounceEnabled="True" ScrollDirectionType="0" DirectionType="Vertical" ctype="ListViewObjectData">
                <Size X="480.0000" Y="518.0000" />
                <Children>
                  <AbstractNodeData Name="item" ActionTag="542944821" Tag="42" IconVisible="False" BottomMargin="446.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
                    <Size X="480.0000" Y="72.0000" />
                    <Children>
                      <AbstractNodeData Name="text" ActionTag="1699587252" Tag="43" IconVisible="False" LeftMargin="12.0000" RightMargin="363.0000" TopMargin="22.0000" BottomMargin="24.0000" FontSize="26" LabelText="你太牛了" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                        <Size X="105.0000" Y="26.0000" />
                        <AnchorPoint ScaleY="0.5000" />
                        <Position X="12.0000" Y="37.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="102" G="44" B="32" />
                        <PrePosition X="0.0250" Y="0.5139" />
                        <PreSize X="0.2188" Y="0.3611" />
                        <FontResource Type="Normal" Path="ui/common/DFYuanW7-GB2312.ttf" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                      <AbstractNodeData Name="line" ActionTag="-1565452320" Tag="64" IconVisible="False" PositionPercentXEnabled="True" LeftMargin="16.0000" RightMargin="16.0000" TopMargin="71.5000" BottomMargin="-0.5000" LeftEage="153" RightEage="153" Scale9OriginX="153" Scale9Width="142" Scale9Height="1" ctype="ImageViewObjectData">
                        <Size X="448.0000" Y="1.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="240.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.5000" />
                        <PreSize X="0.9333" Y="0.0139" />
                        <FileData Type="Normal" Path="ui/chat/text_line.png" Plist="" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint />
                    <Position Y="446.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition Y="0.8610" />
                    <PreSize X="1.0000" Y="0.1390" />
                    <SingleColor A="255" R="150" G="200" B="255" />
                    <FirstColor A="255" R="150" G="200" B="255" />
                    <EndColor A="255" R="255" G="255" B="255" />
                    <ColorVector ScaleY="1.0000" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint />
                <Position X="-243.2732" Y="-215.9577" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <SingleColor A="255" R="150" G="150" B="255" />
                <FirstColor A="255" R="150" G="150" B="255" />
                <EndColor A="255" R="255" G="255" B="255" />
                <ColorVector ScaleY="1.0000" />
              </AbstractNodeData>
              <AbstractNodeData Name="message_on" ActionTag="691808432" Tag="1468" IconVisible="False" LeftMargin="241.3101" RightMargin="-311.3101" TopMargin="-304.8354" BottomMargin="42.8354" LeftEage="23" RightEage="23" TopEage="86" BottomEage="86" Scale9OriginX="23" Scale9OriginY="86" Scale9Width="24" Scale9Height="90" ctype="ImageViewObjectData">
                <Size X="70.0000" Y="262.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="276.3101" Y="173.8354" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="ui/chat/message_on.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="message_off" ActionTag="-1038042941" Tag="1467" IconVisible="False" LeftMargin="241.3101" RightMargin="-311.3101" TopMargin="-304.8354" BottomMargin="42.8354" TouchEnable="True" LeftEage="23" RightEage="23" TopEage="86" BottomEage="86" Scale9OriginX="23" Scale9OriginY="86" Scale9Width="24" Scale9Height="90" ctype="ImageViewObjectData">
                <Size X="70.0000" Y="262.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="276.3101" Y="173.8354" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="ui/chat/message_off.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="face_on" ActionTag="-13979752" Tag="1470" IconVisible="False" LeftMargin="241.3104" RightMargin="-311.3104" TopMargin="-42.7997" BottomMargin="-219.2003" LeftEage="23" RightEage="23" TopEage="86" BottomEage="86" Scale9OriginX="23" Scale9OriginY="86" Scale9Width="24" Scale9Height="90" ctype="ImageViewObjectData">
                <Size X="70.0000" Y="262.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="276.3104" Y="-88.2003" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="ui/chat/face_on.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="face_off" ActionTag="522672581" Tag="1469" IconVisible="False" LeftMargin="241.3104" RightMargin="-311.3104" TopMargin="-42.7997" BottomMargin="-219.2003" TouchEnable="True" LeftEage="23" RightEage="23" TopEage="86" BottomEage="86" Scale9OriginX="23" Scale9OriginY="86" Scale9Width="24" Scale9Height="90" ctype="ImageViewObjectData">
                <Size X="70.0000" Y="262.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="276.3104" Y="-88.2003" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="ui/chat/face_off.png" Plist="" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint />
            <Position X="305.0000" Y="-26.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>