<GameFile>
  <PropertyGroup Name="setViewForGame_2" Type="Node" ID="fe4fd9c6-0ccb-45e9-84ba-652b10e4eff1" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="0" Speed="1.0000" />
      <ObjectData Name="Node" Tag="166" ctype="GameNodeObjectData">
        <Size X="0.0000" Y="0.0000" />
        <Children>
          <AbstractNodeData Name="layer" ActionTag="1977662001" Tag="177" IconVisible="False" LeftMargin="-640.0000" RightMargin="-640.0000" TopMargin="-360.0000" BottomMargin="-360.0000" TouchEnable="True" ClipAble="True" BackColorAlpha="102" ComboBoxIndex="1" ColorAngle="90.0000" LeftEage="422" RightEage="422" TopEage="237" BottomEage="237" Scale9OriginX="-422" Scale9OriginY="-237" Scale9Width="844" Scale9Height="474" ctype="PanelObjectData">
            <Size X="1280.0000" Y="720.0000" />
            <AnchorPoint />
            <Position X="-640.0000" Y="-360.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="main" ActionTag="-884830910" Tag="167" IconVisible="True" ctype="SingleNodeObjectData">
            <Size X="0.0000" Y="0.0000" />
            <Children>
              <AbstractNodeData Name="bg" ActionTag="-1331286638" Tag="168" IconVisible="False" LeftMargin="-417.0009" RightMargin="-392.9991" TopMargin="-324.6200" BottomMargin="-348.3800" Scale9Enable="True" LeftEage="108" RightEage="242" TopEage="135" BottomEage="93" Scale9OriginX="108" Scale9OriginY="135" Scale9Width="460" Scale9Height="246" ctype="ImageViewObjectData">
                <Size X="810.0000" Y="673.0000" />
                <AnchorPoint ScaleX="0.5000" />
                <Position X="-12.0009" Y="-348.3800" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="ui/setView/bg_810.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="title" ActionTag="1511243757" Tag="178" IconVisible="False" LeftMargin="-67.5000" RightMargin="-61.5000" TopMargin="-343.5606" BottomMargin="275.5606" LeftEage="10" RightEage="10" TopEage="23" BottomEage="23" Scale9OriginX="10" Scale9OriginY="23" Scale9Width="109" Scale9Height="22" ctype="ImageViewObjectData">
                <Size X="129.0000" Y="68.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="-3.0000" Y="309.5606" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="ui/setView/title_setting.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="music" ActionTag="829761671" Tag="180" IconVisible="False" LeftMargin="-320.8600" RightMargin="262.8600" TopMargin="-223.2700" BottomMargin="195.2700" FontSize="28" LabelText="音乐" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                <Size X="58.0000" Y="28.0000" />
                <Children>
                  <AbstractNodeData Name="slider_bg" ActionTag="864656874" Tag="1666" IconVisible="False" LeftMargin="92.0001" RightMargin="-194.0001" TopMargin="3.0000" BottomMargin="5.0000" LeftEage="52" RightEage="52" TopEage="9" BottomEage="9" Scale9OriginX="52" Scale9OriginY="9" Scale9Width="56" Scale9Height="2" ctype="ImageViewObjectData">
                    <Size X="160.0000" Y="20.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="172.0001" Y="15.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="2.9655" Y="0.5357" />
                    <PreSize X="2.7586" Y="0.7143" />
                    <FileData Type="Normal" Path="ui/setView/duanbar_back.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="slider" ActionTag="2020366280" Tag="49" IconVisible="False" LeftMargin="93.5000" RightMargin="-195.5000" TopMargin="3.0000" BottomMargin="5.0000" TouchEnable="True" PercentInfo="56" ctype="SliderObjectData">
                    <Size X="160.0000" Y="20.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="173.5000" Y="15.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="2.9914" Y="0.5357" />
                    <PreSize X="2.7586" Y="0.7143" />
                    <ProgressBarData Type="Normal" Path="ui/setView/duan_greenbar.png" Plist="" />
                    <BallNormalData Type="Normal" Path="ui/setView/btn_sound.png" Plist="" />
                    <BallPressedData Type="Normal" Path="ui/setView/btn_sound.png" Plist="" />
                    <BallDisabledData Type="Normal" Path="ui/setView/btn_sound.png" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="-291.8600" Y="209.2700" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="102" G="44" B="32" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <FontResource Type="Normal" Path="ui/common/DFYuanW7-GB2312.ttf" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="voice" ActionTag="604106286" Tag="96" IconVisible="False" LeftMargin="-10.3600" RightMargin="-48.6400" TopMargin="-223.2701" BottomMargin="195.2701" FontSize="28" LabelText="音效" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                <Size X="59.0000" Y="28.0000" />
                <Children>
                  <AbstractNodeData Name="slider_bg" ActionTag="-178237802" Tag="97" IconVisible="False" LeftMargin="92.0001" RightMargin="-193.0001" TopMargin="3.0000" BottomMargin="5.0000" LeftEage="52" RightEage="52" TopEage="9" BottomEage="9" Scale9OriginX="52" Scale9OriginY="9" Scale9Width="56" Scale9Height="2" ctype="ImageViewObjectData">
                    <Size X="160.0000" Y="20.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="172.0001" Y="15.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="2.9153" Y="0.5357" />
                    <PreSize X="2.7119" Y="0.7143" />
                    <FileData Type="Normal" Path="ui/setView/duanbar_back.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="slider" ActionTag="345515813" Tag="98" IconVisible="False" LeftMargin="93.5000" RightMargin="-194.5000" TopMargin="3.0000" BottomMargin="5.0000" TouchEnable="True" PercentInfo="67" ctype="SliderObjectData">
                    <Size X="160.0000" Y="20.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="173.5000" Y="15.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="2.9407" Y="0.5357" />
                    <PreSize X="2.7119" Y="0.7143" />
                    <ProgressBarData Type="Normal" Path="ui/setView/duan_greenbar.png" Plist="" />
                    <BallNormalData Type="Normal" Path="ui/setView/btn_audio.png" Plist="" />
                    <BallPressedData Type="Normal" Path="ui/setView/btn_audio.png" Plist="" />
                    <BallDisabledData Type="Normal" Path="ui/setView/btn_audio.png" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="19.1400" Y="209.2701" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="102" G="44" B="32" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <FontResource Type="Normal" Path="ui/common/DFYuanW7-GB2312.ttf" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="language" ActionTag="1634517339" Tag="241" IconVisible="True" LeftMargin="-322.0000" RightMargin="322.0000" TopMargin="-115.0000" BottomMargin="115.0000" ctype="SingleNodeObjectData">
                <Size X="0.0000" Y="0.0000" />
                <Children>
                  <AbstractNodeData Name="Text_2" ActionTag="2031325373" Tag="103" IconVisible="False" RightMargin="-62.0000" TopMargin="-15.0000" BottomMargin="-15.0000" FontSize="30" LabelText="语言" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                    <Size X="62.0000" Y="30.0000" />
                    <AnchorPoint ScaleY="0.5000" />
                    <Position />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="102" G="44" B="32" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <FontResource Type="Normal" Path="ui/common/DFYuanW7-GB2312.ttf" Plist="" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="CheckBox_1" ActionTag="677618274" Tag="104" IconVisible="False" LeftMargin="81.9997" RightMargin="-281.9997" TopMargin="-28.0000" BottomMargin="-28.0000" TouchEnable="True" CheckedState="True" ctype="CheckBoxObjectData">
                    <Size X="200.0000" Y="56.0000" />
                    <Children>
                      <AbstractNodeData Name="label" ActionTag="2037815582" Tag="105" IconVisible="False" LeftMargin="63.0000" RightMargin="75.0000" TopMargin="12.0000" BottomMargin="14.0000" FontSize="30" LabelText="方言" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                        <Size X="62.0000" Y="30.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="94.0000" Y="29.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="150" G="56" B="35" />
                        <PrePosition X="0.4700" Y="0.5179" />
                        <PreSize X="0.3100" Y="0.5357" />
                        <FontResource Type="Normal" Path="ui/common/DFYuanW7-GB2312.ttf" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="181.9997" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <NormalBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <PressedBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <DisableBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <NodeNormalFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                    <NodeDisableFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="CheckBox_2" ActionTag="195200255" Tag="107" IconVisible="False" LeftMargin="272.0009" RightMargin="-472.0009" TopMargin="-28.0000" BottomMargin="-28.0000" TouchEnable="True" ctype="CheckBoxObjectData">
                    <Size X="200.0000" Y="56.0000" />
                    <Children>
                      <AbstractNodeData Name="label" ActionTag="1855176363" Tag="108" IconVisible="False" LeftMargin="62.0000" RightMargin="46.0000" TopMargin="12.0000" BottomMargin="14.0000" FontSize="30" LabelText="普通话" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                        <Size X="92.0000" Y="30.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="108.0000" Y="29.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="150" G="56" B="35" />
                        <PrePosition X="0.5400" Y="0.5179" />
                        <PreSize X="0.4600" Y="0.5357" />
                        <FontResource Type="Normal" Path="ui/common/DFYuanW7-GB2312.ttf" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="372.0009" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <NormalBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <PressedBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <DisableBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <NodeNormalFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                    <NodeDisableFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint />
                <Position X="-322.0000" Y="115.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
              </AbstractNodeData>
              <AbstractNodeData Name="style" ActionTag="-703982785" Tag="242" IconVisible="True" LeftMargin="-321.9999" RightMargin="321.9999" TopMargin="-23.0000" BottomMargin="23.0000" ctype="SingleNodeObjectData">
                <Size X="0.0000" Y="0.0000" />
                <Children>
                  <AbstractNodeData Name="Text_2" ActionTag="1840856234" Tag="51" IconVisible="False" RightMargin="-62.0000" TopMargin="-15.0000" BottomMargin="-15.0000" FontSize="30" LabelText="版式" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                    <Size X="62.0000" Y="30.0000" />
                    <AnchorPoint ScaleY="0.5000" />
                    <Position />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="102" G="44" B="32" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <FontResource Type="Normal" Path="ui/common/DFYuanW7-GB2312.ttf" Plist="" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="CheckBox_1" ActionTag="638772338" Tag="49" IconVisible="False" LeftMargin="81.9996" RightMargin="-281.9996" TopMargin="-26.8116" BottomMargin="-29.1884" TouchEnable="True" CheckedState="True" ctype="CheckBoxObjectData">
                    <Size X="200.0000" Y="56.0000" />
                    <Children>
                      <AbstractNodeData Name="label" ActionTag="59606110" Tag="50" IconVisible="False" LeftMargin="65.0000" RightMargin="43.0000" TopMargin="12.0000" BottomMargin="14.0000" FontSize="30" LabelText="经典式" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                        <Size X="92.0000" Y="30.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="111.0000" Y="29.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="150" G="56" B="35" />
                        <PrePosition X="0.5550" Y="0.5179" />
                        <PreSize X="0.4600" Y="0.5357" />
                        <FontResource Type="Normal" Path="ui/common/DFYuanW7-GB2312.ttf" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="181.9996" Y="-1.1884" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <NormalBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <PressedBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <DisableBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <NodeNormalFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                    <NodeDisableFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="CheckBox_2" ActionTag="-1133856173" Tag="52" IconVisible="False" LeftMargin="272.0008" RightMargin="-472.0008" TopMargin="-26.8116" BottomMargin="-29.1884" TouchEnable="True" CheckedState="True" ctype="CheckBoxObjectData">
                    <Size X="200.0000" Y="56.0000" />
                    <Children>
                      <AbstractNodeData Name="label" ActionTag="-113633577" Tag="53" IconVisible="False" LeftMargin="65.0000" RightMargin="43.0000" TopMargin="12.0000" BottomMargin="14.0000" FontSize="30" LabelText="现代式" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                        <Size X="92.0000" Y="30.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="111.0000" Y="29.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="150" G="56" B="35" />
                        <PrePosition X="0.5550" Y="0.5179" />
                        <PreSize X="0.4600" Y="0.5357" />
                        <FontResource Type="Normal" Path="ui/common/DFYuanW7-GB2312.ttf" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="372.0008" Y="-1.1884" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <NormalBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <PressedBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <DisableBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <NodeNormalFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                    <NodeDisableFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="CheckBox_3" ActionTag="163206287" Tag="89" IconVisible="False" LeftMargin="472.0010" RightMargin="-672.0010" TopMargin="-26.8116" BottomMargin="-29.1884" TouchEnable="True" CheckedState="True" ctype="CheckBoxObjectData">
                    <Size X="200.0000" Y="56.0000" />
                    <Children>
                      <AbstractNodeData Name="label" ActionTag="925751913" Tag="90" IconVisible="False" LeftMargin="65.0000" RightMargin="68.0000" TopMargin="12.0000" BottomMargin="14.0000" FontSize="30" LabelText="3D式" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                        <Size X="67.0000" Y="30.0000" />
                        <AnchorPoint ScaleY="0.5000" />
                        <Position X="65.0000" Y="29.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="150" G="56" B="35" />
                        <PrePosition X="0.3250" Y="0.5179" />
                        <PreSize X="0.3350" Y="0.5357" />
                        <FontResource Type="Normal" Path="ui/common/DFYuanW7-GB2312.ttf" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="572.0010" Y="-1.1884" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <NormalBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <PressedBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <DisableBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <NodeNormalFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                    <NodeDisableFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint />
                <Position X="-321.9999" Y="23.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
              </AbstractNodeData>
              <AbstractNodeData Name="changeBg" ActionTag="-532325733" Tag="243" IconVisible="True" LeftMargin="-321.9999" RightMargin="321.9999" TopMargin="85.5000" BottomMargin="-85.5000" ctype="SingleNodeObjectData">
                <Size X="0.0000" Y="0.0000" />
                <Children>
                  <AbstractNodeData Name="Text_2" ActionTag="1156106688" Tag="244" IconVisible="False" RightMargin="-62.0000" TopMargin="-15.0000" BottomMargin="-15.0000" FontSize="30" LabelText="版式" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                    <Size X="62.0000" Y="30.0000" />
                    <AnchorPoint ScaleY="0.5000" />
                    <Position />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="102" G="44" B="32" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <FontResource Type="Normal" Path="ui/common/DFYuanW7-GB2312.ttf" Plist="" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="CheckBox_1" ActionTag="-1464550576" Tag="407" IconVisible="False" LeftMargin="81.9996" RightMargin="-281.9996" TopMargin="-40.7502" BottomMargin="-15.2498" TouchEnable="True" CheckedState="True" ctype="CheckBoxObjectData">
                    <Size X="200.0000" Y="56.0000" />
                    <Children>
                      <AbstractNodeData Name="label" ActionTag="-1784753459" Tag="408" IconVisible="False" LeftMargin="65.0000" RightMargin="43.0000" TopMargin="12.0000" BottomMargin="14.0000" FontSize="30" LabelText="舒适黄" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                        <Size X="92.0000" Y="30.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="111.0000" Y="29.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="150" G="56" B="35" />
                        <PrePosition X="0.5550" Y="0.5179" />
                        <PreSize X="0.4600" Y="0.5357" />
                        <FontResource Type="Normal" Path="ui/common/DFYuanW7-GB2312.ttf" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="181.9996" Y="12.7502" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <NormalBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <PressedBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <DisableBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <NodeNormalFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                    <NodeDisableFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="CheckBox_2" ActionTag="109188865" Tag="409" IconVisible="False" LeftMargin="272.0007" RightMargin="-472.0007" TopMargin="-40.7500" BottomMargin="-15.2500" TouchEnable="True" CheckedState="True" ctype="CheckBoxObjectData">
                    <Size X="200.0000" Y="56.0000" />
                    <Children>
                      <AbstractNodeData Name="label" ActionTag="-1121404520" Tag="410" IconVisible="False" LeftMargin="65.0000" RightMargin="43.0000" TopMargin="12.0000" BottomMargin="14.0000" FontSize="30" LabelText="奢华绿" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                        <Size X="92.0000" Y="30.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="111.0000" Y="29.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="150" G="56" B="35" />
                        <PrePosition X="0.5550" Y="0.5179" />
                        <PreSize X="0.4600" Y="0.5357" />
                        <FontResource Type="Normal" Path="ui/common/DFYuanW7-GB2312.ttf" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="372.0007" Y="12.7500" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <NormalBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <PressedBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <DisableBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <NodeNormalFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                    <NodeDisableFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="CheckBox_3" ActionTag="104968009" Tag="511" IconVisible="False" LeftMargin="472.0009" RightMargin="-672.0009" TopMargin="-42.1452" BottomMargin="-13.8548" TouchEnable="True" CheckedState="True" ctype="CheckBoxObjectData">
                    <Size X="200.0000" Y="56.0000" />
                    <Children>
                      <AbstractNodeData Name="label" ActionTag="-842452615" Tag="512" IconVisible="False" LeftMargin="65.0000" RightMargin="43.0000" TopMargin="12.0000" BottomMargin="14.0000" FontSize="30" LabelText="木纹黄" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                        <Size X="92.0000" Y="30.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="111.0000" Y="29.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="150" G="56" B="35" />
                        <PrePosition X="0.5550" Y="0.5179" />
                        <PreSize X="0.4600" Y="0.5357" />
                        <FontResource Type="Normal" Path="ui/common/DFYuanW7-GB2312.ttf" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="572.0009" Y="14.1452" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <NormalBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <PressedBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <DisableBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <NodeNormalFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                    <NodeDisableFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="CheckBox_4" ActionTag="1379104890" Tag="513" IconVisible="False" LeftMargin="81.9996" RightMargin="-281.9996" TopMargin="28.1602" BottomMargin="-84.1602" TouchEnable="True" CheckedState="True" ctype="CheckBoxObjectData">
                    <Size X="200.0000" Y="56.0000" />
                    <Children>
                      <AbstractNodeData Name="label" ActionTag="-1731047179" Tag="514" IconVisible="False" LeftMargin="65.0000" RightMargin="43.0000" TopMargin="12.0000" BottomMargin="14.0000" FontSize="30" LabelText="清新绿" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                        <Size X="92.0000" Y="30.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="111.0000" Y="29.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="150" G="56" B="35" />
                        <PrePosition X="0.5550" Y="0.5179" />
                        <PreSize X="0.4600" Y="0.5357" />
                        <FontResource Type="Normal" Path="ui/common/DFYuanW7-GB2312.ttf" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="181.9996" Y="-56.1602" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <NormalBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <PressedBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <DisableBackFileData Type="Normal" Path="ui/setView/createroom_9.png" Plist="" />
                    <NodeNormalFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                    <NodeDisableFileData Type="Normal" Path="ui/setView/createroom_7.png" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint />
                <Position X="-321.9999" Y="-85.5000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
              </AbstractNodeData>
              <AbstractNodeData Name="btn" ActionTag="2016621514" Tag="53" IconVisible="False" LeftMargin="27.5000" RightMargin="-294.5000" TopMargin="197.2798" BottomMargin="-286.2798" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="237" Scale9Height="67" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="267.0000" Y="89.0000" />
                <Children>
                  <AbstractNodeData Name="text2" ActionTag="1619572105" Tag="847" IconVisible="False" LeftMargin="61.0000" RightMargin="64.0000" TopMargin="22.5000" BottomMargin="29.5000" ctype="SpriteObjectData">
                    <Size X="142.0000" Y="37.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="132.0000" Y="48.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.4944" Y="0.5393" />
                    <PreSize X="0.5318" Y="0.4157" />
                    <FileData Type="Normal" Path="ui/setView/text_dissolve.png" Plist="" />
                    <BlendFunc Src="1" Dst="771" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="161.0000" Y="-241.7798" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="Normal" Path="ui/setView/btn_green_260.png" Plist="" />
                <PressedFileData Type="Normal" Path="ui/setView/btn_green_260.png" Plist="" />
                <NormalFileData Type="Normal" Path="ui/setView/btn_green_260.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="fixbtn" ActionTag="1080526215" Tag="151" IconVisible="False" LeftMargin="-316.0000" RightMargin="50.0000" TopMargin="197.2798" BottomMargin="-286.2798" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="236" Scale9Height="67" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="266.0000" Y="89.0000" />
                <Children>
                  <AbstractNodeData Name="text2" ActionTag="414438360" Tag="152" IconVisible="False" LeftMargin="-1.0000" RightMargin="1.0000" TopMargin="1.5000" BottomMargin="-1.5000" ctype="SpriteObjectData">
                    <Size X="266.0000" Y="89.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="132.0000" Y="43.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.4962" Y="0.4831" />
                    <PreSize X="1.0000" Y="1.0000" />
                    <FileData Type="Normal" Path="ui/setView/icon_xiufu.png" Plist="" />
                    <BlendFunc Src="1" Dst="771" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="-183.0000" Y="-241.7798" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="Normal" Path="ui/setView/btn_yellow_260.png" Plist="" />
                <PressedFileData Type="Normal" Path="ui/setView/btn_yellow_260.png" Plist="" />
                <NormalFileData Type="Normal" Path="ui/setView/btn_yellow_260.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="closeBtn" ActionTag="1465039939" Tag="27" IconVisible="False" LeftMargin="340.0555" RightMargin="-430.0555" TopMargin="-347.0596" BottomMargin="257.0596" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="60" Scale9Height="68" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="90.0000" Y="90.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="385.0555" Y="302.0596" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="Normal" Path="ui/common/btn_close.png" Plist="" />
                <PressedFileData Type="Normal" Path="ui/common/btn_close.png" Plist="" />
                <NormalFileData Type="Normal" Path="ui/common/btn_close.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint />
            <Position />
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