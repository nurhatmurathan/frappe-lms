<template>
	<div v-if="batch.data" class="p-5 rounded-md shadow lg:w-72">
		<Badge
			v-if="batch.data.seat_count && seats_left > 0"
			theme="green"
			class="self-start float-right mb-2"
		>
			{{ seats_left }}
			<span v-if="seats_left > 1">{{ __('Осталось мест') }}</span
			><span v-else-if="seats_left == 1">{{ __('Осталось место') }}</span>
		</Badge>
		<Badge
			v-else-if="batch.data.seat_count && seats_left <= 0"
			theme="red"
			class="self-start float-right mb-2"
		>
			{{ __('Продано') }}
		</Badge>
		<div v-if="batch.data.amount" class="mb-3 text-lg font-semibold">
			{{ formatNumberIntoCurrency(batch.data.amount, batch.data.currency) }}
		</div>
		<div class="flex items-center mb-3">
			<BookOpen class="h-4 w-4 stroke-1.5 mr-2 text-gray-700" />
			<span> {{ batch.data.courses.length }} {{ __('Курсы') }} </span>
		</div>
		<DateRange
			:startDate="batch.data.start_date"
			:endDate="batch.data.end_date"
			class="mb-3"
		/>
		<div class="flex items-center mb-3">
			<Clock class="h-4 w-4 stroke-1.5 mr-2 text-gray-700" />
			<span>
				{{ formatTime(batch.data.start_time) }} -
				{{ formatTime(batch.data.end_time) }}
			</span>
		</div>
		<div v-if="batch.data.timezone" class="flex items-center">
			<Globe class="h-4 w-4 stroke-1.5 mr-2 text-gray-700" />
			<span>
				{{ batch.data.timezone }}
			</span>
		</div>
		<router-link
			v-if="isModerator || isStudent"
			:to="{
				name: 'Batch',
				params: {
					batchName: batch.data.name,
				},
			}"
		>
			<Button variant="solid" class="w-full mt-4">
				<span>
					{{ isModerator ? __('Управлять группой') : __('Посетить группу') }}
				</span>
			</Button>
		</router-link>
		<router-link
			:to="{
				name: 'Billing',
				params: {
					type: 'batch',
					name: batch.data.name,
				},
			}"
			v-else-if="batch.data.paid_batch && batch.data.seats_left"
		>
			<Button v-if="!isStudent" class="w-full mt-4" variant="solid">
				<span>
					{{ __('Зарегистрироваться сейчас') }}
				</span>
			</Button>
		</router-link>
		<Button
			variant="solid"
			class="w-full mt-2"
			v-else-if="batch.data.allow_self_enrollment && batch.data.seats_left"
			@click="enrollInBatch()"
		>
			{{ __('Записаться сейчас') }}
		</Button>
		<router-link
			v-if="isModerator"
			:to="{
				name: 'BatchForm',
				params: {
					batchName: batch.data.name,
				},
			}"
		>
			<Button class="w-full mt-2">
				<span>
					{{ __('Редактировать') }}
				</span>
			</Button>
		</router-link>
	</div>
</template>
<script setup>
import DateRange from '@/components/Common/DateRange.vue'
import { formatNumberIntoCurrency, formatTime, showToast } from '@/utils'
import { Badge, Button, createResource } from 'frappe-ui'
import { BookOpen, Clock, Globe } from 'lucide-vue-next'
import { computed, inject } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const user = inject('$user')

const props = defineProps({
	batch: {
		type: Object,
		default: null,
	},
})

const enroll = createResource({
	url: 'lms.lms.utils.enroll_in_batch',
	makeParams(values) {
		return {
			batch: props.batch.data.name,
		}
	},
})

const enrollInBatch = () => {
	if (!user.data) {
		window.location.href = `/login?redirect-to=/batches/details/${props.batch.data.name}`
	}
	enroll.submit(
		{},
		{
			onSuccess(data) {
				showToast(__('Успех'), __('Вы записаны в эту группу'), 'check')
				router.push({
					name: 'Batch',
					params: {
						batchName: props.batch.data.name,
					},
				})
			},
		},
	)
}

const seats_left = computed(() => {
	if (props.batch.data?.seat_count) {
		return props.batch.data?.seat_count - props.batch.data?.students?.length
	}
	return null
})

const isStudent = computed(() => {
	return props.batch.data?.students?.includes(user.data?.name)
})

const isModerator = computed(() => {
	return user.data?.is_moderator
})
</script>
