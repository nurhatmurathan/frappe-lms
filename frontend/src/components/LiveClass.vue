<template>
	<div class="flex items-center justify-between mb-5">
		<div class="text-lg font-semibold">
			{{ __('Живой класс') }}
		</div>
		<Button v-if="user.data.is_moderator" @click="openLiveClassModal">
			<template #prefix>
				<Plus class="w-4 h-4" />
			</template>
			<span>
				{{ __('Добавить') }}
			</span>
		</Button>
	</div>
	<div v-if="liveClasses.data?.length" class="grid grid-cols-2 gap-5">
		<div
			v-for="cls in liveClasses.data"
			class="flex flex-col h-full p-3 text-sm text-gray-700 border rounded-md"
		>
			<div class="mb-4 text-lg font-semibold text-gray-900">
				{{ cls.title }}
			</div>
			<div class="mb-4 text-sm leading-5 text-gray-700">
				{{ cls.description }}
			</div>
			<div class="flex items-center mb-2">
				<Calendar class="w-4 h-4 stroke-1.5 text-gray-700" />
				<span class="ml-2">
					{{ dayjs(cls.date).format('DD MMMM YYYY') }}
				</span>
			</div>
			<div class="flex items-center mb-5">
				<Clock class="w-4 h-4 stroke-1.5" />
				<span class="ml-2">
					{{ formatTime(cls.time) }}
				</span>
			</div>
			<div class="flex items-center mt-auto space-x-2 text-gray-900">
				<a
					v-if="user.data?.is_moderator || user.data?.is_evaluator"
					:href="cls.start_url"
					target="_blank"
					class="inline-flex items-center justify-center w-1/2 gap-2 px-2 text-base text-gray-800 transition-colors bg-gray-100 rounded cursor-pointer focus:outline-none hover:bg-gray-200 active:bg-gray-300 focus-visible:ring focus-visible:ring-gray-400 h-7"
				>
					<Monitor class="h-4 w-4 stroke-1.5" />
					{{ __('Начать') }}
				</a>
				<a
					v-if="cls.date <= dayjs().format('YYYY-MM-DD')"
					:href="cls.join_url"
					target="_blank"
					class="inline-flex items-center justify-center w-full gap-2 px-2 text-base text-gray-800 transition-colors bg-gray-100 rounded cursor-pointer focus:outline-none hover:bg-gray-200 active:bg-gray-300 focus-visible:ring focus-visible:ring-gray-400 h-7"
				>
					<Video class="h-4 w-4 stroke-1.5" />
					{{ __('Присоединиться') }}
				</a>
			</div>
		</div>
	</div>
	<div v-else class="text-sm italic text-gray-600">
		{{ __('Нет запланированных живых классов') }}
	</div>
	<LiveClassModal
		:batch="props.batch"
		v-model="showLiveClassModal"
		v-model:reloadLiveClasses="liveClasses"
	/>
</template>
<script setup>
import LiveClassModal from '@/components/Modals/LiveClassModal.vue'
import { formatTime } from '@/utils/'
import { Button, createListResource } from 'frappe-ui'
import { Calendar, Clock, Monitor, Plus, Video } from 'lucide-vue-next'
import { inject, ref } from 'vue'

const user = inject('$user')
const showLiveClassModal = ref(false)
const dayjs = inject('$dayjs')

const props = defineProps({
	batch: {
		type: String,
		required: true,
	},
})

const liveClasses = createListResource({
	doctype: 'LMS Live Class',
	filters: {
		batch_name: props.batch,
	},
	fields: [
		'title',
		'description',
		'time',
		'date',
		'start_url',
		'join_url',
		'owner',
	],
	orderBy: 'date',
	auto: true,
})

const openLiveClassModal = () => {
	showLiveClassModal.value = true
}
</script>
