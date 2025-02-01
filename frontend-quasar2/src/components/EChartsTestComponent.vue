<template>
  <q-page class="flex flex-center">
    <div class="q-pa-md" style="width: 100%; max-width: 800px;">
      <q-card flat>
        <q-card-section>
          <h2 class="text-center">VChart Test</h2>
        </q-card-section>
        <q-card-section>
          <v-charts :option="option" style="height: 400px; width: 400px;" />
        </q-card-section>
        <q-card-section>
          <h2 class="text-center">VChart Test 2</h2>
        </q-card-section>
        <q-card-section>
          <v-charts :option="chartOptionsSimple" style="height: 400px; width: 400px;" />
        </q-card-section>
      </q-card>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { use } from 'echarts/core';
import VCharts from 'vue-echarts';
import { CanvasRenderer } from 'echarts/renderers';
import { PieChart } from 'echarts/charts';
import { GridComponent, TooltipComponent, TitleComponent, LegendComponent } from 'echarts/components';

// Register ECharts modules
use([CanvasRenderer, GridComponent, TooltipComponent, TitleComponent, LegendComponent, PieChart]);

const option = {
              textStyle: {
                fontFamily: 'Inter, "Helvetica Neue", Arial, sans-serif',
              },
              title: {
                text: 'Traffic Sources',
                left: 'center',
              },
              tooltip: {
                trigger: 'item',
                formatter: '{a} <br/>{b} : {c} ({d}%)',
              },
              legend: {
                orient: 'vertical',
                left: 'left',
                data: [
                  'Direct',
                  'Email',
                  'Ad Networks',
                  'Video Ads',
                  'Search Engines',
                ],
              },
              series: [
                {
                  name: 'Traffic Sources',
                  type: 'pie',
                  radius: '55%',
                  center: ['50%', '60%'],
                  data: [
                    { value: 335, name: 'Direct' },
                    { value: 310, name: 'Email' },
                    { value: 234, name: 'Ad Networks' },
                    { value: 135, name: 'Video Ads' },
                    { value: 1548, name: 'Search Engines' },
                  ],
                  emphasis: {
                    itemStyle: {
                      shadowBlur: 10,
                      shadowOffsetX: 0,
                      shadowColor: 'rgba(0, 0, 0, 0.5)',
                    },
                  },
                },
              ],
            };

const chartOptionsSimple = {
  xAxis: {
    type: 'category',
    data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
  },
  yAxis: {
    type: 'value'
  },
  series: [
    {
      data: [150, 230, 224, 218, 135, 147, 260],
      type: 'line'
    }
  ]
};


</script>

<style>
.q-page {
  background: #f5f5f5;
}
</style>
