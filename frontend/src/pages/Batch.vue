<template>
	<div v-if="user.data?.is_moderator || isStudent" class="">
		<header
			class="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-3 py-2.5 sm:px-5"
		>
			<Breadcrumbs class="h-7" :items="breadcrumbs" />
			<div class="flex items-center space-x-2">
				<Button
					v-if="user.data?.is_moderator"
					@click="openCertificateDialog = true"
				>
					{{ __('Сгенерировать сертификаты') }}
				</Button>
				<Button v-if="user.data?.is_moderator" @click="openAnnouncementModal()">
					<span>
						{{ __('Сделать объявление') }}
					</span>
					<template #suffix>
						<SendIcon class="h-4 stroke-1.5" />
					</template>
				</Button>
			</div>
		</header>
		<div v-if="batch.data" class="grid grid-cols-[70%,30%] h-screen">
			<div class="border-r">
				<Tabs
					v-model="tabIndex"
					:tabs="tabs"
					tablistClass="overflow-y-hidden bg-white"
				>
					<template #tab="{ tab, selected }" class="overflow-x-hidden">
						<div>
							<button
								class="group -mb-px flex items-center gap-1 border-b border-transparent py-2.5 text-base text-gray-600 duration-300 ease-in-out hover:border-gray-400 hover:text-gray-900"
								:class="{ 'text-gray-900': selected }"
							>
								<component
									v-if="tab.icon"
									:is="tab.icon"
									class="h-4 stroke-1.5"
								/>
								{{ __(tab.label) }}
								<Badge
									v-if="tab.count"
									:class="{
										'text-gray-900 border border-gray-900': selected,
									}"
									variant="subtle"
									theme="gray"
									size="sm"
								>
									{{ tab.count }}
								</Badge>
							</button>
						</div>
					</template>
					<template #default="{ tab }">
						<div class="px-5 pt-5 pb-10">
							<div v-if="tab.label == 'Courses'">
								<BatchCourses :batch="batch.data.name" />
							</div>
							<div v-else-if="tab.label == 'Dashboard' && isStudent">
								<BatchDashboard :batch="batch" :isStudent="isStudent" />
							</div>
							<div v-else-if="tab.label == 'Dashboard'">
								<BatchStudents :batch="batch.data" />
							</div>
							<div v-else-if="tab.label == 'Live Class'">
								<LiveClass :batch="batch.data.name" />
							</div>
							<div v-else-if="tab.label == 'Assessments'">
								<Assessments :batch="batch.data.name" />
							</div>
							<div v-else-if="tab.label == 'Announcements'">
								<Announcements :batch="batch.data.name" />
							</div>
							<div v-else-if="tab.label == 'Discussions'">
								<Discussions
									doctype="LMS Batch"
									:docname="batch.data.name"
									:title="__('Обсуждения')"
									:key="batch.data.name"
									:singleThread="true"
									:scrollToBottom="true"
								/>
							</div>
						</div>
					</template>
				</Tabs>
			</div>
			<div class="p-5">
				<div class="mb-2 text-xl font-semibold">
					{{ batch.data.title }}
				</div>
				<div v-html="batch.data.description" class="mb-2 leading-5"></div>

				<div class="flex items-center mb-5 avatar-group overlap">
					<div
						class="h-6 mr-1"
						:class="{
							'avatar-group overlap': batch.data.instructors.length > 1,
						}"
					>
						<UserAvatar
							v-for="instructor in batch.data.instructors"
							:user="instructor"
						/>
					</div>
					<CourseInstructors :instructors="batch.data.instructors" />
				</div>
				<DateRange
					:startDate="batch.data.start_date"
					:endDate="batch.data.end_date"
					class="mb-3"
				/>
				<div class="flex items-center mb-4">
					<Clock class="h-4 w-4 stroke-1.5 mr-2 text-gray-700" />
					<span>
						{{ formatTime(batch.data.start_time) }} -
						{{ formatTime(batch.data.end_time) }}
					</span>
				</div>
				<div v-if="batch.data.timezone" class="flex items-center mb-4">
					<Globe class="h-4 w-4 stroke-1.5 mr-2 text-gray-700" />
					<span>
						{{ batch.data.timezone }}
					</span>
				</div>
			</div>
			<AnnouncementModal
				v-model="showAnnouncementModal"
				:batch="batch.data.name"
				:students="batch.data.students"
			/>
		</div>
	</div>
	<div v-else-if="!user.data?.name" class="">
		<div class="w-1/3 mx-auto my-32 text-base border rounded-md">
			<div class="px-5 py-3 font-medium border-b">
				<span
					class="inline-flex items-center before:bg-red-600 before:w-2 before:h-2 before:rounded-md before:mr-2"
				></span>
				{{ __('Не разрешено') }}
			</div>
			<div class="px-5 py-3">
				<div v-if="user.data" class="mb-4 leading-6">
					{{
						__(
							'Вы не являетесь участником этой группы. Пожалуйста, ознакомьтесь с нашими предстоящими группами.',
						)
					}}
				</div>
				<div v-else class="mb-4 leading-6">
					{{
						__('Пожалуйста, войдите, чтобы получить доступ к этой странице.')
					}}
				</div>
				<router-link
					v-if="user.data"
					:to="{
						name: 'Batches',
						params: {
							batchName: batch.data?.name,
						},
					}"
				>
					<Button variant="solid" class="w-full">
						{{ __('Предстоящие группы') }}
					</Button>
				</router-link>
				<Button
					v-else
					variant="solid"
					class="w-full"
					@click="redirectToLogin()"
				>
					{{ __('Войти') }}
				</Button>
			</div>
		</div>
	</div>
	<BulkCertificates v-model="openCertificateDialog" :batch="batch.data" />
</template>
<script setup>
import Announcements from '@/components/Annoucements.vue'
import Assessments from '@/components/Assessments.vue'
import BatchCourses from '@/components/BatchCourses.vue'
import BatchDashboard from '@/components/BatchDashboard.vue'
import BatchStudents from '@/components/BatchStudents.vue'
import DateRange from '@/components/Common/DateRange.vue'
import CourseInstructors from '@/components/CourseInstructors.vue'
import Discussions from '@/components/Discussions.vue'
import LiveClass from '@/components/LiveClass.vue'
import AnnouncementModal from '@/components/Modals/AnnouncementModal.vue'
import BulkCertificates from '@/components/Modals/BulkCertificates.vue'
import UserAvatar from '@/components/UserAvatar.vue'
import { formatTime, updateDocumentTitle } from '@/utils'
import { Badge, Breadcrumbs, Button, createResource, Tabs } from 'frappe-ui'
import {
	BookOpen,
	BookOpenCheck,
	Clock,
	Globe,
	Laptop,
	LayoutDashboard,
	Mail,
	MessageCircle,
	SendIcon,
} from 'lucide-vue-next'
import { computed, inject, ref } from 'vue'

const user = inject('$user')
const showAnnouncementModal = ref(false)
const openCertificateDialog = ref(false)

const props = defineProps({
	batchName: {
		type: String,
		required: true,
	},
})

const batch = createResource({
	url: 'lms.lms.utils.get_batch_details',
	cache: ['batch', props.batchName],
	params: {
		batch: props.batchName,
	},
	auto: true,
})

const breadcrumbs = computed(() => {
	let crumbs = [{ label: 'Группы', route: { name: 'Batches' } }]
	if (!isStudent.value) {
		crumbs.push({
			label: 'Детали',
			route: {
				name: 'BatchDetail',
				params: {
					batchName: batch.data?.name,
				},
			},
		})
	}
	crumbs.push({
		label: batch?.data?.title,
		route: { name: 'Batch', params: { batchName: props.batchName } },
	})
	return crumbs
})

const isStudent = computed(() => {
	return (
		user?.data &&
		batch.data?.students?.length &&
		batch.data?.students.includes(user.data.name)
	)
})

const tabIndex = ref(0)
const tabs = computed(() => {
	let batchTabs = []
	batchTabs.push({
		label: 'Dashboard',
		icon: LayoutDashboard,
	})

	batchTabs.push({
		label: 'Courses',
		icon: BookOpen,
	})

	batchTabs.push({
		label: 'Live Class',
		icon: Laptop,
	})

	if (user.data?.is_moderator) {
		batchTabs.push({
			label: 'Assessments',
			icon: BookOpenCheck,
		})
	}

	batchTabs.push({
		label: 'Announcements',
		icon: Mail,
	})

	batchTabs.push({
		label: 'Discussions',
		icon: MessageCircle,
	})
	return batchTabs
})

const redirectToLogin = () => {
	window.location.href = `/login?redirect-to=/batches`
}

const openAnnouncementModal = () => {
	showAnnouncementModal.value = true
}

const pageMeta = computed(() => {
	return {
		title: batch.data?.title,
		description: batch.data?.description,
	}
})

updateDocumentTitle(pageMeta)
</script>
