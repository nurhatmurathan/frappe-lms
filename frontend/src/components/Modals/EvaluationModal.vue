<template>
	<Dialog
		v-model="show"
		:options="{
			title: __('Запланировать оценку'),
			size: 'xl',
			actions: [
				{
					label: __('Отправить'),
					variant: 'solid',
					onClick: (close) => submitEvaluation(close),
				},
			],
		}"
	>
		<template #body-content>
			<div class="flex flex-col gap-4">
				<div>
					<div class="mb-1.5 text-sm text-gray-600">
						{{ __('Курс') }}
					</div>
					<Select v-model="evaluation.course" :options="getCourses()" />
				</div>
				<div>
					<div class="mb-1.5 text-sm text-gray-600">
						{{ __('Дата') }}
					</div>
					<FormControl type="date" v-model="evaluation.date" />
				</div>
				<div v-if="slots.data?.length">
					<div class="mb-1.5 text-sm text-gray-600">
						{{ __('Выберите слот') }}
					</div>
					<div class="grid grid-cols-2 gap-2">
						<div v-for="slot in slots.data">
							<div
								class="p-2 text-base text-center bg-gray-200 border rounded-md cursor-pointer"
								@click="saveSlot(slot)"
								:class="{
									'border-gray-900': evaluation.start_time == slot.start_time,
								}"
							>
								{{ formatTime(slot.start_time) }} -
								{{ formatTime(slot.end_time) }}
							</div>
						</div>
					</div>
				</div>
				<div
					v-else-if="evaluation.course && evaluation.date"
					class="text-sm italic text-red-600"
				>
					{{ __('Нет доступных слотов на эту дату.') }}
				</div>
			</div>
		</template>
	</Dialog>
</template>
<script setup>
import { Dialog, createResource, Select, FormControl } from 'frappe-ui'
import { defineModel, reactive, watch, inject } from 'vue'
import { createToast, formatTime } from '@/utils/'

const user = inject('$user')
const dayjs = inject('$dayjs')
const show = defineModel()
const evaluations = defineModel('reloadEvals')

const props = defineProps({
	courses: {
		type: Array,
		default: [],
	},
	batch: {
		type: String,
		default: null,
	},
	endDate: {
		type: String,
		default: null,
	},
})

let evaluation = reactive({
	course: '',
	date: '',
	start_time: '',
	end_time: '',
	day: '',
	batch: props.batch,
	member: user.data.name,
})

const createEvaluation = createResource({
	url: 'frappe.client.insert',
	makeParams(values) {
		return {
			doc: {
				doctype: 'LMS Certificate Request',
				batch_name: values.batch,
				...values,
			},
		}
	},
})

function submitEvaluation(close) {
	createEvaluation.submit(evaluation, {
		validate() {
			if (!evaluation.course) {
				return 'Пожалуйста, выберите курс.'
			}
			if (!evaluation.date) {
				return 'Пожалуйста, выберите дату.'
			}
			if (!evaluation.start_time) {
				return 'Пожалуйста, выберите слот.'
			}
			if (dayjs(evaluation.date).isBefore(dayjs(), 'day')) {
				return 'Пожалуйста, выберите будущую дату.'
			}
			if (dayjs(evaluation.date).isAfter(dayjs(props.endDate), 'day')) {
				return `Пожалуйста, выберите дату до даты окончания ${dayjs(
					props.endDate,
				).format('DD MMMM YYYY')}.`
			}
		},
		onSuccess() {
			evaluations.value.reload()
			close()
		},
		onError(err) {
			let message = err.messages?.[0] || err
			let unavailabilityMessage

			if (typeof message === 'string') {
				unavailabilityMessage = message?.includes('unavailable')
			} else {
				unavailabilityMessage = false
			}

			createToast({
				title: unavailabilityMessage ? __('Оценщик недоступен') : '',
				text: message,
				icon: unavailabilityMessage ? 'alert-circle' : 'x',
				iconClasses: 'bg-yellow-600 text-white rounded-md p-px',
				position: 'top-center',
				timeout: 10,
			})
		},
	})
}

const getCourses = () => {
	let courses = []
	for (const course of props.courses) {
		if (course.evaluator) {
			courses.push({
				label: course.title,
				value: course.course,
			})
		}
	}
	return courses
}

const slots = createResource({
	url: 'lms.lms.doctype.course_evaluator.course_evaluator.get_schedule',
	makeParams(values) {
		return {
			course: values.course,
			date: values.date,
			batch: props.batch,
		}
	},
})

watch(
	() => evaluation.date,
	(date) => {
		evaluation.start_time = ''
		if (date && evaluation.course) {
			slots.submit(evaluation)
		}
	},
)

watch(
	() => evaluation.course,
	(course) => {
		evaluation.date = ''
		evaluation.start_time = ''
		slots.reset()
	},
)

const saveSlot = (slot) => {
	evaluation.start_time = slot.start_time
	evaluation.end_time = slot.end_time
	evaluation.day = slot.day
}
</script>
